import { ref, watch } from 'vue'

const STORAGE_KEY = 'tnBusStops'

export function useStops() {
  const stops = ref(JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'))

  watch(stops, val => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(val))
  }, { deep: true })

  function addStop(name) {
    if (stops.value.includes(name)) return false
    stops.value = [...stops.value, name]
    return true
  }

  function removeStop(name) {
    stops.value = stops.value.filter(s => s !== name)
  }

  return { stops, addStop, removeStop }
}
