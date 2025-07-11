import { StyleSheet, View } from 'react-native';
import { WebIconView } from 'react-native-web-icon';

export default function App() {
  return (
    <View style={styles.container}>
      <WebIconView url="https://amazone.com" style={styles.box} />
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
  },
});
