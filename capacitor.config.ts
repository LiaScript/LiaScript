import { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'liascript.io',
  appName: 'LiaScript',
  webDir: 'dist',
  server: { androidScheme: 'http' },
  plugins: {
    SystemBars: {
      insetsHandling: 'css',
      style: 'light',
      overlaysWebView: true,
      backgroundColor: '#00000000', // Fully transparent status bar
    },
  },
}

export default config
