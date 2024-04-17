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
      <Button title="Press me" onPress={onPress} />
      <Button title="Cancel by id" onPress={cancelById} />
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
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
