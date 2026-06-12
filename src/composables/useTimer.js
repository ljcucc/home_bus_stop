import { ref, watch, onUnmounted } from 'vue'

export function useTimer(fn, interval = 30000) {
  const running = ref(false)
  let timer = null

  function start() {
    stop()
    if (interval <= 0) return
    running.value = true
    timer = setInterval(fn, interval)
  }

  function stop() {
    running.value = false
    if (timer !== null) {
      clearInterval(timer)
      timer = null
    }
  }

  onUnmounted(stop)

  return { start, stop, running }
}
