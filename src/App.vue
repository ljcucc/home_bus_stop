<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { useTheme } from 'vuetify'
import BusSearch from './components/BusSearch.vue'
import BusStopCard from './components/BusStopCard.vue'
import { useStops } from './composables/useStops'
import { useGeolocation } from './composables/useGeolocation'

const { stops, addStop, removeStop } = useStops()
const {
  latitude: userLat,
  longitude: userLon,
  isTracking,
  start: startGeolocation,
} = useGeolocation()

const theme = useTheme()
const isDark = computed(() => theme.global.name.value === 'dark')

const hideNobus = ref(localStorage.getItem('tnBusHideNobus') !== 'false')
const isFullscreen = ref(false)
const refreshKey = ref(0)
const lastUpdate = ref('')
const errorMsg = ref('')
let refreshTimer = null

const now = ref(new Date())
let clockTimer

const timeString = computed(() =>
  now.value.toLocaleDateString('zh-TW', {
    year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short',
  }) + '  ' +
  now.value.toLocaleTimeString('zh-TW', {
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  }),
)

const geoStatusText = computed(() => {
  if (isTracking.value) return '定位中…'
  if (userLat.value != null) return `已定位 (${userLat.value.toFixed(4)}, ${userLon.value.toFixed(4)})`
  return ''
})

function toggleTheme() {
  const next = isDark.value ? 'light' : 'dark'
  theme.global.name.value = next
  localStorage.setItem('tnBusTheme', next)
}

function refreshAll() {
  refreshKey.value++
  lastUpdate.value = new Date().toLocaleTimeString('zh-TW', {
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  })
}

function scheduleRefresh() {
  if (refreshTimer) clearInterval(refreshTimer)
  if (stops.value.length === 0) return
  refreshTimer = setInterval(refreshAll, 30000)
}

watch(stops, () => scheduleRefresh(), { deep: true })
watch(hideNobus, v => localStorage.setItem('tnBusHideNobus', v))

function handleAddStop(name) {
  if (!addStop(name)) {
    errorMsg.value = `「${name}」已在清單中`
    setTimeout(() => { errorMsg.value = '' }, 3000)
  }
  nextTick(refreshAll)
}

function handleRemoveStop(name) {
  removeStop(name)
  if (stops.value.length === 0) lastUpdate.value = ''
}

function handleError(msg) {
  errorMsg.value = msg
  setTimeout(() => { errorMsg.value = '' }, 4000)
}

onMounted(() => {
  now.value = new Date()
  clockTimer = setInterval(() => { now.value = new Date() }, 1000)
  if (stops.value.length > 0) {
    refreshAll()
    scheduleRefresh()
  }
})

onUnmounted(() => {
  clearInterval(clockTimer)
  if (refreshTimer) clearInterval(refreshTimer)
})
</script>

<template>
  <v-app :class="{ 'fullscreen-mode': isFullscreen }">
    <v-app-bar
      elevation="2"
      :color="isFullscreen ? 'transparent' : 'surface'"
      :class="{ 'border-bottom': !isFullscreen }"
    >
      <template #prepend>
        <v-avatar size="36" class="mr-1">🚏</v-avatar>
      </template>

      <v-toolbar-title class="pl-0">
        <div class="font-weight-black text-primary" style="font-size: 1.2rem; letter-spacing: 2px;">
          大台南公車立牌
        </div>
        <div class="text-caption text-on-surface-variant" style="line-height: 1.2;">
          {{ timeString }}
        </div>
      </v-toolbar-title>

      <template #append>
        <v-btn
          icon
          variant="text"
          :title="isDark ? '切換淺色模式' : '切換深色模式'"
          @click="toggleTheme"
        >
          <v-icon>{{ isDark ? 'mdi-white-balance-sunny' : 'mdi-weather-night' }}</v-icon>
        </v-btn>
        <v-btn
          icon
          variant="text"
          :title="isFullscreen ? '離開全螢幕' : '全螢幕'"
          @click="isFullscreen = !isFullscreen"
        >
          <v-icon>{{ isFullscreen ? 'mdi-fullscreen-exit' : 'mdi-fullscreen' }}</v-icon>
        </v-btn>
      </template>
    </v-app-bar>

    <v-main>
      <v-container
        class="px-4 py-4"
        :class="{ 'container-fullscreen': isFullscreen }"
        :style="{ maxWidth: isFullscreen ? '1200px' : '860px' }"
      >
        <v-expand-transition>
          <div v-if="!isFullscreen" class="mb-2">
            <BusSearch
              :user-lat="userLat"
              :user-lon="userLon"
              @add-stop="handleAddStop"
              @locate="startGeolocation"
            />
            <div
              v-if="geoStatusText"
              class="d-flex align-center ga-1 mt-2"
            >
              <v-icon size="x-small" color="green">mdi-map-marker</v-icon>
              <span class="text-caption text-green">{{ geoStatusText }}</span>
            </div>
          </div>
        </v-expand-transition>

        <div class="d-flex align-center justify-space-between flex-wrap ga-2 mb-3 mt-2">
          <div class="d-flex align-center ga-1">
            <v-icon size="small" color="on-surface-variant">mdi-format-list-bulleted</v-icon>
            <span class="text-body-2 font-weight-bold text-on-surface-variant">我的站牌</span>
          </div>
          <div class="d-flex ga-1">
            <v-btn
              size="small"
              :variant="hideNobus ? 'tonal' : 'outlined'"
              color="primary"
              @click="hideNobus = !hideNobus"
            >
              <v-icon start size="x-small">mdi-bus-alert</v-icon>
              隱藏未發車
            </v-btn>
            <v-btn
              size="small"
              variant="outlined"
              color="on-surface-variant"
              @click="refreshAll"
            >
              <v-icon start size="x-small">mdi-refresh</v-icon>
              重新整理
            </v-btn>
          </div>
        </div>

        <v-expand-transition>
          <v-alert
            v-if="errorMsg"
            type="error"
            closable
            density="compact"
            class="mb-3 rounded-lg"
            @click:close="errorMsg = ''"
          >
            {{ errorMsg }}
          </v-alert>
        </v-expand-transition>

        <v-expand-transition mode="out-in">
          <div v-if="stops.length === 0 && !errorMsg" key="empty" class="text-center py-10">
            <div class="text-h3 mb-3">🚌</div>
            <p class="text-body-2 text-on-surface-variant">
              在上方搜尋站牌名稱加入<br>即會顯示即時到站資訊
            </p>
          </div>

          <div v-else key="stops" class="d-flex flex-column ga-3">
            <BusStopCard
              v-for="stopName in stops"
              :key="stopName"
              :stop-name="stopName"
              :user-lat="userLat"
              :user-lon="userLon"
              :hide-nobus="hideNobus"
              :refresh-key="refreshKey"
              :is-fullscreen="isFullscreen"
              @remove="handleRemoveStop(stopName)"
              @error="handleError"
            />
          </div>
        </v-expand-transition>

        <div class="text-center py-4 text-caption text-on-surface-variant">
          <span v-if="lastUpdate">最後更新：{{ lastUpdate }}</span>
          <span v-else>等待更新…</span>
        </div>
      </v-container>
    </v-main>
  </v-app>
</template>

<style>
.fullscreen-mode .bus-search {
  display: none !important;
}

.fullscreen-mode .v-container {
  padding-top: 0 !important;
}

.fullscreen-mode .v-app-bar {
  border-bottom: none !important;
}

.border-bottom {
  border-bottom: 1px solid rgba(var(--v-border-color), 0.08);
}

.v-alert {
  border-radius: 10px !important;
}
</style>
