<a href="https://guulabs.com">
  <img src="./docs/cover.png" width="100%" />
</a>

<div align="center">

  <h1>
    @guulabs/react-native-local-notifications <br/> <br/>
  </h1>

  <b>Schedule local notifications from React Native on iOS and Android.</b>
</div>

## Installation

```sh
yarn add @guulabs/react-native-local-notifications
```

## Usage

```js
import {
  scheduleNotification,
  onNotificationEvent,
  cancelScheduledNotifications,
  cancelAllScheduledNotifications,
} from '@guulabs/react-native-local-notifications';

// ...

const id = await scheduleNotification(
  {
    title: 'Title',
    body: 'This is the body of the local notification.',
  },
  {
    timestamp: Date.now() + 5000,
  }
);

// Listen for notification related events.
useEffect(() => {
  const unsubscribe = onNotificationEvent(({ type, detail }) => {
    if(type === "notificationPressed") {
      // Subscribe to this event to handle when a notification is pressed. This can be used for both background and foreground notifications.
      console.log('On Notification Pressed:', type, detail);
    } else if(type === "notificationDelivered") {
      // Subscribe to this event to handle when a notification is delivered and the app is in the foreground.
      console.log('On Notification Delivered:', type, detail);
    }
  });
  return () => {
    unsubscribe();
  }
}, []);

// Cancel a list of notification ids
await cancelScheduledNotifications([id, "another_id1", "another_id2"]);

// Cancel all
await cancelAllScheduledNotifications();
```
## iOS
Display [a notification banner](https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/banner) for foreground notifications.
```js
const id = await scheduleNotification(
  {
    title: 'Title',
    body: 'New',
    data: {
      key: 'value',
    },
    ios: {
      foregroundPresentationOptions: {
        banner: true,
      },
    },
  },
  {
    timestamp: Date.now() + 5000,
  }
);
```

## Android

Set a custom icon and set an accent color.
```js
const id = await scheduleNotification(
  {
    title: 'Title',
    body: 'This is the body of the local notification.',
    android: {
      smallIcon: 'ic_launcher',
      color: '#0000ff',
    }
  },
  {
    timestamp: Date.now() + 5000,
  }
);
```

## API

| Param name | Type                                         | Default                        | Description                                                                                              |
|------------|----------------------------------------------|--------------------------------|----------------------------------------------------------------------------------------------------------|
| title      | `string`                                     |    -                           | Title of the local notification.       |
| body       | `string`                                     |    -                           |  The body for the local notification.  |
| ios        | `foregroundPresentationOptions: { banner: bool }` | `foregroundPresentationOptions: { banner: true }` | Show a [notification banner](https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/banner) for the notification events dispatched while the app is in foreground |
| android    | ` { smallIcon: string, color: string } `     | `{ smallIcon: 'ic_launcher' }` | Use `smallIcon` to set a custom resource name (drawable or mipmap) for the notification icon on Android. </br> Use `color` to set a hex accent color for the notification on Android. |
| timestamp  | `number`                                     |    -                           | The date in milliseconds when the local notfication should be dispatched. |

## Does this library interfere with notifications from other libraries?
No. This library marks the notifications it sends. Internally, notifications from other libraries are ignored.

## Should I use it?

This library was desinged to minimize the JS footprint, it contains only a few fuctions defined on the JS side. If your use case requires more than sending some simple local notifications, I strongly advive to use [Notifee](https://github.com/invertase/notifee). 

## Show your support

* 🏋️‍♂️ Follow me on Twitter [@GutuCristian](https://twitter.com/GutuCristian) or [LinkedIn](https://www.linkedin.com/in/cristiangutu/) for updates.
* ⭐️ Star this repo.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
