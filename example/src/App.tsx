import React, { useCallback } from 'react';

import { StyleSheet, View, Button } from 'react-native';
import {
  scheduleNotification,
  cancelScheduledNotifications,
  cancelAllScheduledNotifications,
} from '@guulabs/react-native-local-notifications';

export default function App() {
  const onPress = useCallback(async () => {
    const id = await scheduleNotification(
      {
        title: 'Title',
        body: 'New',
        android: {
          smallIcon: 'ic_launcher',
          color: '#0000ff',
        },
      },
      {
        timestamp: Date.now() + 5000,
      }
    );
    console.log('Scheduled notification with id:', id);
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
