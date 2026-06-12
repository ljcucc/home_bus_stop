<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { searchStops, calcDistance, formatDist } from '../composables/useBusApi'

const props = defineProps({
  userLat: { type: Number, default: null },
  userLon: { type: Number, default: null },
})

const emit = defineEmits(['add-stop', 'locate'])

const query = ref('')
const suggestions = ref([])
const showSuggestions = ref(false)
const searching = ref(false)
const searchRef = ref(null)
let debounceTimer = null

const hasLocation = computed(() =>
  props.userLat != null && props.userLon != null,
)

function onInput(val) {
  query.value = val
  clearTimeout(debounceTimer)
  if (val.trim().length < 1) {
    showSuggestions.value = false
    return
  }
  debounceTimer = setTimeout(() => doSearch(val.trim()), 250)
}

async function doSearch(keyword) {
  searching.value = true
  try {
    const data = await searchStops(keyword)
    if (Array.isArray(data)) {
      suggestions.value = data.map(s => {
        let dist = -1
        if (hasLocation.value && s.lat) {
          dist = calcDistance(props.userLat, props.userLon, parseFloat(s.lat), parseFloat(s.lon))
        }
        return {
          name: s.name,
          dist,
          distText: dist > 0 ? formatDist(dist) : '',
        }
      })
      showSuggestions.value = suggestions.value.length > 0
    } else {
      suggestions.value = []
      showSuggestions.value = false
    }
  } catch {
    suggestions.value = []
    showSuggestions.value = false
  } finally {
    searching.value = false
  }
}

function selectStop(s) {
  emit('add-stop', s.name)
  query.value = ''
  showSuggestions.value = false
}

function handleSearchClick() {
  if (query.value.trim()) doSearch(query.value.trim())
}

function handleKeydown(e) {
  if (e.key === 'Enter' && query.value.trim()) {
    doSearch(query.value.trim())
  }
}

function onClickOutside(e) {
  if (searchRef.value && !searchRef.value.contains(e.target)) {
    showSuggestions.value = false
  }
}

onMounted(() => document.addEventListener('click', onClickOutside))
onUnmounted(() => document.removeEventListener('click', onClickOutside))
</script>

<template>
  <div ref="searchRef" class="bus-search w-100">
    <v-text-field
      v-model="query"
      :loading="searching"
      placeholder="搜尋站牌名稱…"
      hide-details
      density="comfortable"
      variant="solo-filled"
      flat
      clearable
      bg-color="surface-variant"
      class="flex-grow-1"
      @update:model-value="onInput"
      @keydown="handleKeydown"
      @click:clear="showSuggestions = false"
      @click:append-inner="handleSearchClick"
    >
      <template #prepend-inner>
        <v-icon color="on-surface-variant">mdi-magnify</v-icon>
      </template>
      <template #append-inner>
        <v-btn
          size="small"
          variant="text"
          :color="hasLocation ? 'green' : 'on-surface-variant'"
          class="mr-n2"
          @click="emit('locate')"
        >
          <v-icon>{{ hasLocation ? 'mdi-map-marker' : 'mdi-map-marker-outline' }}</v-icon>
        </v-btn>
      </template>
    </v-text-field>

    <v-expand-transition>
      <v-card
        v-if="showSuggestions"
        class="mt-1 suggestions-card"
        elevation="8"
        rounded="lg"
      >
        <v-list density="compact" bg-color="surface">
          <v-list-item
            v-for="s in suggestions"
            :key="s.name"
            @click="selectStop(s)"
            class="suggestion-item"
          >
            <div class="d-flex align-center justify-space-between w-100">
              <span class="font-weight-bold text-body-2 text-on-surface">{{ s.name }}</span>
              <span v-if="s.dist > 0" class="text-caption text-on-surface-variant ml-2">
                {{ s.distText }}
              </span>
            </div>
          </v-list-item>
        </v-list>
      </v-card>
    </v-expand-transition>
  </div>
</template>

<style scoped>
.bus-search {
  position: relative;
  margin-bottom: 8px;
}
.suggestions-card {
  position: absolute;
  z-index: 100;
  width: 100%;
  left: 0;
}
.suggestion-item {
  border-bottom: 1px solid rgba(var(--v-border-color), 0.06);
}
.suggestion-item:last-child {
  border-bottom: none;
}
</style>
