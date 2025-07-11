# react-native-web-icon

A React Native library that displays website icons with automatic fallback to favicon if the primary icon is not found.

## Features

- 🌐 Displays website icons based on URL
- 🔄 Automatically falls back to favicon if the primary icon is not found
- 🖼️ Prioritizes high-quality Apple touch icons when available
- 📱 Works on both iOS and Android
- 🔄 Caches icons for better performance
- 🎨 Customizable size through style props

## Installation

```sh
npm install react-native-web-icon
# or
yarn add react-native-web-icon
```

### iOS

```sh
cd ios && pod install
```

## Usage

```jsx
import { WebIconView } from "react-native-web-icon";
import { StyleSheet, View } from 'react-native';

function App() {
  return (
    <View style={styles.container}>
      {/* Display the icon for a website */}
      <WebIconView url="https://github.com" style={styles.icon} />

      {/* Another example with different size */}
      <WebIconView url="https://reactnative.dev" style={styles.largeIcon} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: {
    width: 32,
    height: 32,
  },
  largeIcon: {
    width: 64,
    height: 64,
  },
});
```

## How It Works

1. When you provide a URL to the `WebIconView` component, it first attempts to fetch the website's icon by parsing the HTML and looking for icon links in the `<head>` section.
2. The library prioritizes high-quality icons in this order:
   - Apple touch icons (typically higher quality)
   - Regular icon links
3. If no suitable icon is found or if the icon is in `.ico` format (which may not be supported well on all platforms), the library automatically falls back to using Google's favicon service.
4. The library caches icons to improve performance and reduce network requests.

## Props

| Prop  | Type       | Description                                |
|-------|------------|--------------------------------------------|
| url   | string     | The URL of the website to fetch icon from  |
| style | ViewStyle  | Style for the icon view (width, height, etc.) |

## Platform Support

- ✅ iOS
- ✅ Android

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
