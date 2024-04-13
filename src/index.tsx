import { NativeModules, Platform } from 'react-native';
import type {
  Notification,
  NotificationTrigger,
} from './NativeLocalNotifications';

const LINKING_ERROR =
  `The package 'react-native-local-notifications' doesn't seem to be linked. Make sure: \n\n` +
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
  return LocalNotifications.scheduleNotification(notification, trigger);
}
