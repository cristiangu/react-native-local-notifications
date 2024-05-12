import React, { useCallback, useEffect, useState } from 'react';

import { StyleSheet, View, Button } from 'react-native';
import {
  scheduleNotification,
  cancelScheduledNotifications,
  cancelAllScheduledNotifications,
  onForegroundEvent,
  getInitialNotification,
} from '@guulabs/react-native-local-notifications';

export default function App() {
  const [ids, setIds] = useState<string[]>([]);

  const onInitialNotification = useCallback(async () => {
    const initialNotification = await getInitialNotification();
    console.log('Initial notification:', initialNotification);
  }, []);

  useEffect(() => {
    onInitialNotification();

    // @ts-expect-error
    onForegroundEvent(({ type, detail }) => {
      console.log('Aaaaa:', type, detail);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onPress = useCallback(async () => {
    const id = await scheduleNotification(
      {
        title: 'Title',
        body: 'New',
        android: {
          smallIcon: 'ic_launcher',
          color: '#0000ff',
        },
        data: {
          key: 'value',
        },
      },
      {
        timestamp: Date.now() + 5000,
      }
    );
    setIds((prevIds) => [...prevIds, id]);
    console.log('Scheduled notification with id:', id);
  }, []);

  const cancelById = useCallback(async () => {
    await cancelScheduledNotifications(ids);
  }, [ids]);

  const cancelAll = useCallback(async () => {
    await cancelAllScheduledNotifications();
  }, []);

  return (
    <View style={styles.container}>
      <Button title="Schedule notification" onPress={onPress} />
      <View style={styles.verticalSpacer} />
      <Button title="Cancel by id" onPress={cancelById} />
      <View style={styles.verticalSpacer} />
      <Button title="Cancel all" onPress={cancelAll} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  verticalSpacer: {
    height: 20,
  },
});
