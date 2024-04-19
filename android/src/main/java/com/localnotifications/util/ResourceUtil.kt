package com.localnotifications.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.media.RingtoneManager
import android.net.Uri
import android.util.Log
import android.util.TypedValue
import com.facebook.common.executors.CallerThreadExecutor
import com.facebook.common.references.CloseableReference
import com.facebook.datasource.DataSource
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.imagepipeline.datasource.BaseBitmapDataSubscriber
import com.facebook.imagepipeline.image.CloseableImage
import com.facebook.imagepipeline.request.ImageRequestBuilder
import com.facebook.react.runtime.internal.bolts.Task
import com.facebook.react.runtime.internal.bolts.TaskCompletionSource
import java.util.Locale


object ResourceUtil {
  private const val TAG = "ResourceUtil"
  private const val LOCAL_RESOURCE_SCHEME = "res"

  @Volatile
  private var sResourceIdCache: MutableMap<String, Int>? = null
  val resourceIdCache: MutableMap<String, Int>?
    get() {
      if (sResourceIdCache == null) {
        synchronized(ResourceUtil::class.java) {
          if (sResourceIdCache == null) {
            sResourceIdCache = HashMap()
          }
        }
      }
      return sResourceIdCache
    }

  fun getImageSourceUri(source: String?, context: Context): Uri {
    return try {
      val uri = Uri.parse(source)
      // verify a scheme is set,
      // so that relative uri (used by static resources) are not handled
      if (uri.scheme == null) {
        getResourceDrawableUri(source, context)
      } else uri
    } catch (e: Exception) {
      getResourceDrawableUri(source, context)
    }
  }

  fun getResourceDrawableUri(name: String?, context: Context): Uri {
    val resId = getResourceIdByName(name, "drawable", context)
    return if (resId > 0) Uri.Builder().scheme(LOCAL_RESOURCE_SCHEME).path(resId.toString())
      .build() else Uri.EMPTY
  }

  /**
   * Returns a circular Bitmap from another bitmap. The original bitmap can be any shape.
   *
   * @param bitmap
   * @return Bitmap
   */
  fun getCircularBitmap(bitmap: Bitmap): Bitmap {
    val output: Bitmap
    val srcRect: Rect
    val dstRect: Rect
    val r: Float
    val width = bitmap.width
    val height = bitmap.height
    if (width > height) {
      output = Bitmap.createBitmap(height, height, Bitmap.Config.ARGB_8888)
      val left = (width - height) / 2
      val right = left + height
      srcRect = Rect(left, 0, right, height)
      dstRect = Rect(0, 0, height, height)
      r = (height / 2).toFloat()
    } else {
      output = Bitmap.createBitmap(width, width, Bitmap.Config.ARGB_8888)
      val top = (height - width) / 2
      val bottom = top + width
      srcRect = Rect(0, top, width, bottom)
      dstRect = Rect(0, 0, width, width)
      r = (width / 2).toFloat()
    }
    val canvas = Canvas(output)
    val color = Color.RED
    val paint = Paint()
    paint.isAntiAlias = true
    canvas.drawARGB(0, 0, 0, 0)
    paint.color = color
    canvas.drawCircle(r, r, r, paint)
    paint.setXfermode(PorterDuffXfermode(PorterDuff.Mode.SRC_IN))
    canvas.drawBitmap(bitmap, srcRect, dstRect, paint)
    return output
  }

  /**
   * Returns a Bitmap from any given HTTP image URL, or local resource.
   *
   * @param imageUrl
   * @return Bitmap or null if the image failed to load
   */
  fun getImageBitmapFromUrl(imageUrl: String, context: Context): Task<Bitmap> {
    val imageUri: Uri
    val bitmapTCS = TaskCompletionSource<Bitmap>()
    val bitmapTask: Task<Bitmap> = bitmapTCS.task
    imageUri = if (!imageUrl.contains("/")) {
      val imageResourceUrl = getImageResourceUrl(imageUrl, context)
      if (imageResourceUrl == null) {
        bitmapTCS.setResult(null)
        return bitmapTask
      }
      getImageSourceUri(imageResourceUrl, context)
    } else {
      getImageSourceUri(imageUrl, context)
    }
    val imageRequest = ImageRequestBuilder.newBuilderWithSource(imageUri).build()

    // Needed when the app is killed, and the Fresco hasn't yet been initialized by React Native
    if (!Fresco.hasBeenInitialized()) {
      Log.w(TAG, "Fresco initializing natively by react-native-local-notifications");
      Fresco.initialize(context.applicationContext)
    }
    val dataSource = Fresco.getImagePipeline()
      .fetchDecodedImage(imageRequest, context.applicationContext)
    dataSource.subscribe(
      object : BaseBitmapDataSubscriber() {
        override fun onNewResultImpl(bitmap: Bitmap?) {
          bitmapTCS.setResult(bitmap)
        }

        override fun onFailureImpl(
          dataSource: DataSource<CloseableReference<CloseableImage?>>
        ) {
          Log.e(
            TAG,
            "Failed to load an image: $imageUrl", dataSource.failureCause
          )
          bitmapTCS.setResult(null)
        }
      },
      CallerThreadExecutor.getInstance()
    )
    return bitmapTask
  }

  /**
   * Returns a resource path for a local resource
   *
   * @param icon
   * @return
   */
  private fun getImageResourceUrl(icon: String, context: Context): String? {
    var resourceId = getResourceIdByName(icon, "mipmap", context)
    if (resourceId == 0) {
      resourceId = getResourceIdByName(icon, "drawable", context)
    }
    if (resourceId == 0) {
      return null
    }
    return if (resourceId > 0) Uri.Builder()
      .scheme(LOCAL_RESOURCE_SCHEME)
      .path(resourceId.toString())
      .build()
      .toString() else Uri.EMPTY.toString()
  }

  /**
   * Gets a resource ID by name.
   *
   * @param resourceName
   * @return integer or 0 if not found
   */
  fun getImageResourceId(resourceName: String?, context: Context): Int {
    var resourceId = getResourceIdByName(resourceName, "mipmap", context)
    if (resourceId == 0) {
      resourceId = getResourceIdByName(resourceName, "drawable", context)
    }
    return resourceId
  }

  /** Attempts to find a resource id by name and type  */
  private fun getResourceIdByName(name: String?, type: String, context: Context): Int {
    var name = name
    if (name == null || name.isEmpty()) {
      return 0
    }
    name = name.lowercase(Locale.getDefault()).replace("-", "_")
    val key = name + "_" + type
    synchronized(ResourceUtil::class.java) {
      if (resourceIdCache!!.containsKey(key)) {
        // noinspection ConstantConditions
        return resourceIdCache!![key]!!
      }
      val packageName = context.packageName
      val id = context.resources.getIdentifier(name, type, packageName)
      resourceIdCache!![key] = id
      return id
    }
  }

  fun getSoundName(sound: Uri?, context: Context): String? {
    if (sound == null) return null
    if (sound.toString().contains("android.resource")) {
      val soundFile = sound.lastPathSegment
      try {
        val resourceId = Integer.valueOf(soundFile)
        Log.e(
          TAG, "Loaded sound by resource id. New app builds will fail to play sound. Create a new"
            + " channel to resolve. Issue #341"
        )
        if (resourceId != 0) {
          val value = TypedValue()
          context.resources.getValue(resourceId, value, true)
          val soundString = value.string
          if (soundString != null || soundString?.length!! > 0) {
            return soundString.toString().replace("res/raw/", "")
          }
        }
      } catch (nfe: NumberFormatException) {
        // This implies the sound URI last path segment was by file name, not resourceId
        // They were by resourceId prior to issue #341 where we learned that leads to unstable URIs
        // Now we verify the file exists but use the file name from the raw directory
        // We still attempt to resolve by resourceId above to gracefully handle URIs created via our
        // previous behavior
        return soundFile
      }
    }

    // TODO parse system sounds
    return null
  }

  fun getSoundUri(sound: String?, context: Context): Uri? {
    return if (sound == null) {
      null
    } else if (sound.contains("://")) {
      Uri.parse(sound)
    } else if (sound.equals("default", ignoreCase = true)) {
      RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
    } else {
      // The API user is attempting to set a sound by file name, verify it exists
      var soundResourceId = getResourceIdByName(sound, "raw", context)
      if (soundResourceId == 0 && sound.contains(".")) {
        soundResourceId = getResourceIdByName(sound.substring(0, sound.lastIndexOf('.')), "raw", context)
      }
      if (soundResourceId == 0) {
        null
      } else Uri.parse("android.resource://" + context.packageName + "/raw/" + sound)

      // Use the actual sound name vs the resource ID, to obtain a stable URI, Issue #341
    }
  }
}
