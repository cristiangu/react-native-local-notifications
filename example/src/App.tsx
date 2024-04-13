import React, { useCallback } from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { scheduleNotification } from 'react-native-local-notifications';

export default function App() {
  const onPress = useCallback(async () => {
    await scheduleNotification(
      {
        id: 'my_id',
        title: 'Hello',
        body: 'World',
      },
      {
        timestamp: Date.now() + 5000,
      }
    );
  }, []);

  return (
    <View style={styles.container}>
      <Button title="Press me" onPress={onPress} />
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
