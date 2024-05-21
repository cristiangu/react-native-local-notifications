import { NativeModules, Platform, NativeEventEmitter } from 'react-native';
import type {
  Notification,
  NotificationTrigger,
} from './NativeLocalNotifications';
import { isFunction } from './validate';

export const kReactNativeGuuNotificationEvent =
  'app.guulabs.notification-event';

const LINKING_ERROR =
  `The package '@guulabs/react-native-local-notifications' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const LocalNotificationsModule = isTurboModuleEnabled
  ? require('./NativeLocalNotifications').default
  : NativeModules.LocalNotifications;

const LocalNotifications = LocalNotificationsModule
  ? LocalNotificationsModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function scheduleNotification(
  notification: Notification,
  trigger: NotificationTrigger
): Promise<string> {
  const data = {
    ...notification.data,
  };
  const _notification = { ...notification, data: data };
  return LocalNotifications.scheduleNotification(_notification, trigger);
}

export function cancelScheduledNotifications(ids: string[]): Promise<string> {
  return LocalNotifications.cancelScheduledNotifications(ids);
}

export function cancelAllScheduledNotifications(): Promise<string> {
  return LocalNotifications.cancelAllScheduledNotifications();
}

export function onForegroundEvent(
  observer: (event: Event) => void
): () => void {
  if (!isFunction(observer)) {
    throw new Error(
      "guulabs.onForegroundEvent(*) 'observer' expected a function."
    );
  }

  const eventEmitter = new NativeEventEmitter(LocalNotifications);
  let subscription = null;
  subscription = eventEmitter.addListener(
    kReactNativeGuuNotificationEvent,
    ({ type, detail }) => {
      // @ts-expect-error
      observer({ type, detail });
    }
  );

  return (): void => {
    subscription.remove();
  };
}
