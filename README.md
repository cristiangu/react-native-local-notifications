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

// Cancel scheduled notifications
await cancelScheduledNotifications([id, "another_id1", "another_id2"]);

// Cancel all
await cancelAllScheduledNotifications();
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
| Param name | Type                                         | Default                        | Description                                                                                                                                          |
|------------|----------------------------------------------|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| title      | `string`                                     |    -                           | Title of the local notification.       |
| body       | `string`                                     |    -                           |  The body for the local notification.  |
| android    | ` { smallIcon: string, color: string } `     | `{ smallIcon: 'ic_launcher' }` | Use `smallIcon` to set a custom resource name (drawable or mipmap) for the notification icon on Android. </br> Use `color` to set a hex accent color for the notification on Android. |
| timestamp  | `number`                                     |    -                           | The date in milliseconds when the local notfication should be dispatched. |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
