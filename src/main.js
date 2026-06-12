import { createApp } from 'vue'
import { createVuetify } from 'vuetify'
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import App from './App.vue'

const savedTheme = localStorage.getItem('tnBusTheme') || 'dark'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: savedTheme,
    themes: {
      dark: {
        dark: true,
        colors: {
          background: '#0a0a1a',
          surface: '#111122',
          'surface-variant': '#1a1a2e',
          primary: '#e94560',
          secondary: '#0f3460',
          accent: '#f0c040',
          'on-surface': '#ffffff',
          'on-surface-variant': '#b0b0b0',
        },
      },
      light: {
        dark: false,
        colors: {
          background: '#f5f5f5',
          surface: '#ffffff',
          'surface-variant': '#fafafa',
          primary: '#e53935',
          secondary: '#1565c0',
          accent: '#f9a825',
          'on-surface': '#1a1a1a',
          'on-surface-variant': '#666666',
        },
      },
    },
  },
})

createApp(App).use(vuetify).mount('#app')
