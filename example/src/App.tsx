import React, { useCallback } from 'react';

import { StyleSheet, View, Button } from 'react-native';
import {
  scheduleNotification,
  cancelScheduledNotifications,
  cancelAllScheduledNotifications,
} from 'react-native-local-notifications';

export default function App() {
  const onPress = useCallback(async () => {
    await scheduleNotification(
      {
        id: 'my_id',
        title: 'Title',
        body: 'New',
        data: {
          url: 'https://example.com',
        },
        android: {
          smallIcon: 'ic_launcher',
        },
      },
      {
        timestamp: Date.now() + 5000,
      }
    );
  }, []);

  const cancelById = useCallback(async () => {
    await cancelScheduledNotifications(['my_id']);
  }, []);

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
