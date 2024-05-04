<a href="https://guulabs.com">
  <img src="./docs/cover.png" width="100%" />
</a>

<div align="center">

  <h1>
    📢<br/>
    @guulabs/react-native-local-notifications <br/> <br/>
  </h1>

  <b>Lightweight local notifications scheduler on iOS and Android for React Native.</b>
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

// Cancel some scheduled notifications
await cancelScheduledNotifications([id, "another_id1", "another_id2"]);

// Cancel all
await cancelAllScheduledNotifications();
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
