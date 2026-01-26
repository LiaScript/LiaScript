import { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'liascript.io',
  appName: 'LiaScript',
  webDir: 'dist',
  server: {
    androidScheme: 'http',
  },
}

export default config
