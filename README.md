# Tainan Bus Stop Sign

A real-time bus departure information board for Tainan City. Built with Vue 3 and Vuetify.

## Features

- **Search & Track** – Search for bus stops by name and add them to your list
- **Real-time Arrivals** – Displays estimated arrival times for every route at each stop, fetched from the official Tainan City bus API
- **Geolocation** – Optionally use your current location to see distance to each stop
- **Hide Non-Operating** – Toggle to hide routes that are not currently running
- **Fullscreen Mode** – Turn the page into a dedicated information display
- **Dark / Light Theme** – Switch between dark and light modes

## Usage

```bash
npm install
npm run dev      # development server
npm run build    # production build
npm run preview  # preview production build
```

## Data Source

Real-time data is provided by [Tainan City Bus Information System](https://2384.tainan.gov.tw/).

## Tech Stack

- Vue 3 (Composition API)
- Vuetify 3
- Vite
- Tainan City Bus API v2

## License

MIT
