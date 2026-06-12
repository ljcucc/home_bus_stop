<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const now = ref(new Date())
let timer

function update() { now.value = new Date() }

onMounted(() => {
  update()
  timer = setInterval(update, 1000)
})

onUnmounted(() => clearInterval(timer))
</script>

<template>
  <div class="bus-header">
    <div class="text-h5 font-weight-black text-primary letter-spacing-3">
      🚏 大台南公車立牌
    </div>
    <div class="text-caption text-grey mt-1">
      {{ now.toLocaleDateString('zh-TW', { year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short' }) }}
      {{ now.toLocaleTimeString('zh-TW', { hour: '2-digit', minute: '2-digit', second: '2-digit' }) }}
    </div>
  </div>
</template>

<style scoped>
.bus-header {
  text-align: center;
  padding: 16px 0 14px;
  border-bottom: 3px solid rgb(var(--v-theme-primary));
  margin-bottom: 20px;
}

:fullscreen .bus-header,
:global(.fullscreen-mode) .bus-header {
  padding: 10px 0 10px;
  margin-bottom: 14px;
}

:fullscreen .bus-header :deep(.text-h5),
:global(.fullscreen-mode) .bus-header :deep(.text-h5) {
  font-size: 1.625rem !important;
}

:fullscreen .bus-header :deep(.text-caption),
:global(.fullscreen-mode) .bus-header :deep(.text-caption) {
  font-size: 1.125rem !important;
  color: #999 !important;
}

.letter-spacing-3 {
  letter-spacing: 3px;
}
</style>
