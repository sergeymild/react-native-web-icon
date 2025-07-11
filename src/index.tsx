import {
  type ImageStyle,
  Platform,
  requireNativeComponent,
  type StyleProp,
  UIManager,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-web-icon' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type WebIconProps = {
  url: string;
  style: StyleProp<ImageStyle>;
};

const ComponentName = 'WebIconView';

export const WebIconView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<WebIconProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
