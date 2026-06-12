<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { fetchStopData, processStopData } from '../composables/useBusApi'
import RouteRow from './RouteRow.vue'

const props = defineProps({
  stopName: { type: String, required: true },
  userLat: { type: Number, default: null },
  userLon: { type: Number, default: null },
  hideNobus: { type: Boolean, default: false },
  refreshKey: { type: Number, default: 0 },
  isFullscreen: { type: Boolean, default: false },
})

const emit = defineEmits(['remove', 'error'])

const sides = ref([])
const loading = ref(true)
const errorMsg = ref('')

async function loadData() {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await fetchStopData(props.stopName)
    if (data && data.length > 0) {
      sides.value = processStopData(data, props.userLat, props.userLon)
    } else {
      sides.value = []
      errorMsg.value = '查無此站牌資料'
    }
  } catch {
    sides.value = []
    errorMsg.value = '資料讀取失敗'
    emit('error', `${props.stopName}: 資料讀取失敗`)
  } finally {
    loading.value = false
  }
}

watch(() => props.refreshKey, loadData)
watch(() => props.userLat, loadData)
watch(() => props.userLon, loadData)

const visibleSides = computed(() =>
  sides.value
    .map(side => ({
      ...side,
      routes: props.hideNobus
        ? side.routes.filter(r => r.timeClass !== 'nobus')
        : side.routes,
    }))
    .filter(side => side.routes.length > 0),
)

onMounted(loadData)
</script>

<template>
  <v-card
    rounded="xl"
    :elevation="isFullscreen ? 0 : 2"
    class="stop-card"
  >
    <v-card-title class="d-flex align-center justify-space-between px-4 py-3">
      <div class="d-flex align-center ga-2 text-truncate">
        <span class="text-h6 font-weight-black text-on-surface text-truncate">{{ stopName }}</span>
        <v-chip
          v-if="sides.length === 1"
          size="x-small"
          variant="flat"
          color="on-surface-variant"
          label
        >
          {{ sides[0].locId }}
        </v-chip>
      </div>
      <v-btn
        icon="mdi-close"
        size="x-small"
        variant="text"
        color="on-surface-variant"
        @click="emit('remove')"
      />
    </v-card-title>

    <v-divider />

    <v-card-text class="pa-0">
      <div v-if="loading" class="text-center py-8 text-on-surface-variant">
        <v-progress-circular indeterminate size="24" color="primary" />
        <div class="text-caption mt-2">載入中…</div>
      </div>

      <div v-else-if="errorMsg" class="pa-4 text-caption text-primary">{{ errorMsg }}</div>

      <div v-else-if="visibleSides.length === 0" class="pa-4 text-caption text-on-surface-variant">
        無營運路線
      </div>

      <div v-else>
        <div
          v-for="(side, si) in visibleSides"
          :key="side.locId"
          class="px-4"
          :class="{ 'pt-1': true }"
        >
          <div
            class="d-flex align-center justify-space-between pb-1 mb-1"
            :class="{ 'pt-3': si > 0 }"
          >
            <span class="text-body-2 font-weight-bold text-on-surface-variant">
              📍 {{ side.locId }}{{ side.distText ? ' · ' + side.distText : '' }}
            </span>
            <v-chip
              size="x-small"
              variant="flat"
              color="on-surface-variant"
              label
            >
              {{ side.dirLabel }}
            </v-chip>
          </div>
          <RouteRow
            v-for="route in side.routes"
            :key="route.routeName + route.dir"
            :route="route"
          />
          <v-divider v-if="si < visibleSides.length - 1" class="mt-1" />
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.stop-card {
  border: 1px solid rgba(var(--v-border-color), 0.08);
}

:fullscreen .stop-card,
:global(.fullscreen-mode) .stop-card {
  border: 1px solid rgba(var(--v-border-color), 0.12);
}

:fullscreen .card-title :deep(.text-h6),
:global(.fullscreen-mode) .card-title :deep(.text-h6) {
  font-size: 1.75rem !important;
}

:fullscreen .stop-card :deep(.text-body-2),
:global(.fullscreen-mode) .stop-card :deep(.text-body-2) {
  font-size: 0.9375rem !important;
}

@media (max-width: 500px) {
  .stop-card :deep(.text-h6) {
    font-size: 1.125rem !important;
  }
}
</style>
