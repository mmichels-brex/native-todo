import { requireNativeView } from 'expo';
import { StyleSheet } from 'react-native';

// The whole app lives in native/ (SwiftUI). React Native only mounts it.
const NativeApp = requireNativeView('NativeAppHost');

export default function App() {
  return <NativeApp style={StyleSheet.absoluteFill} />;
}
