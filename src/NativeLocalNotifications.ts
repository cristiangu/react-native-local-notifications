import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface NotificationAndroid {
  smallIcon?: string;
  color?: string;
}

export interface Notification {
  /**
   * A unique identifier for your notification.
   *
   * Notifications with the same ID will be created as the same instance, allowing you to update
   * a notification which already exists on the device.
   *
   * Defaults to a random string if not provided.
   */
  id?: string;

  /**
   * The notification title which appears above the body text.
   */
  title?: string;

  /**
   * The notification subtitle, which appears on a new line below/next the title.
   */
  subtitle?: string | undefined;

  /**
   * The main body content of a notification.
   */
  body?: string | undefined;

  /**
   * Additional data to store on the notification.
   *
   * Data can be used to provide additional context to your notification which can be retrieved
   * at a later point in time (e.g. via an event).
   */
  data?: { [key: string]: string | object | number };

  android?: NotificationAndroid;
}
export interface NotificationTrigger {
  /**
   * The timestamp when the notification should first be shown, in milliseconds since 1970.
   */
  timestamp: number;
}
export interface Spec extends TurboModule {
  scheduleNotification(
    notification: Notification,
    trigger: NotificationTrigger
  ): Promise<string>;

  cancelScheduledNotifications(ids: string[]): Promise<string>;

  cancelAllScheduledNotifications(): Promise<string>;

  addListener: (eventType: string) => void;
  removeListeners: (count: number) => void;

  getInitialNotification(): Promise<Notification | null>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('LocalNotifications');
