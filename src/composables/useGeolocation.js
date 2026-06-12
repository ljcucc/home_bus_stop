import { ref, onUnmounted } from 'vue'

const LAT_KEY = 'tnBusLat'
const LON_KEY = 'tnBusLon'

export function useGeolocation() {
  const latitude = ref(null)
  const longitude = ref(null)
  const isTracking = ref(false)
  const error = ref(null)
  let watchId = null

  const savedLat = localStorage.getItem(LAT_KEY)
  const savedLon = localStorage.getItem(LON_KEY)
  if (savedLat && savedLon) {
    latitude.value = parseFloat(savedLat)
    longitude.value = parseFloat(savedLon)
  }

  function start() {
    if (!navigator.geolocation) {
      error.value = '不支援定位功能'
      return
    }
    isTracking.value = true
    watchId = navigator.geolocation.watchPosition(
      pos => {
        latitude.value = pos.coords.latitude
        longitude.value = pos.coords.longitude
        localStorage.setItem(LAT_KEY, pos.coords.latitude)
        localStorage.setItem(LON_KEY, pos.coords.longitude)
        error.value = null
      },
      err => {
        error.value = err.message
        isTracking.value = false
      },
      { enableHighAccuracy: true, timeout: 10000 },
    )
  }

  onUnmounted(() => {
    if (watchId !== null) navigator.geolocation.clearWatch(watchId)
  })

  return { latitude, longitude, isTracking, error, start }
}
