<script setup>
defineProps({
  route: { type: Object, required: true },
})

const timeColorMap = {
  arriving: '#4caf50',
  approaching: '#ff9800',
  coming: '#42a5f5',
  nobus: null,
}
</script>

<template>
  <div class="d-flex align-center py-2 route-row">
    <span class="font-weight-black mr-3 route-name">{{ route.routeName }}</span>
    <span class="flex-grow-1 text-body-2 text-on-surface-variant mr-2 text-truncate route-dest">
      往 {{ route.dest }}
    </span>
    <span
      class="font-weight-bold text-no-wrap text-right route-time"
      :class="route.timeClass"
      :style="timeColorMap[route.timeClass] ? { color: timeColorMap[route.timeClass] } : {}"
    >
      {{ route.timeLabel }}
    </span>
  </div>
</template>

<style scoped>
.route-row {
  border-bottom: 1px solid rgba(var(--v-border-color), 0.04);
}
.route-row:last-child {
  border-bottom: none;
}
.route-name {
  min-width: 100px;
  color: rgb(var(--v-theme-accent));
  font-size: 1.125rem;
  letter-spacing: 0.5px;
}
.route-dest {
  min-width: 0;
}
.route-time {
  min-width: 72px;
  font-variant-numeric: tabular-nums;
  font-size: 1.25rem;
}
.route-time.nobus {
  font-size: 0.8125rem;
  font-weight: 400;
  color: rgba(var(--v-theme-on-surface), 0.38);
}

@media (max-width: 500px) {
  .route-name {
    min-width: 75px;
    font-size: 0.9375rem;
  }
  .route-dest {
    font-size: 0.8125rem;
  }
  .route-time {
    min-width: 56px;
    font-size: 1.0625rem;
  }
}

:fullscreen .route-name,
:global(.fullscreen-mode) .route-name {
  min-width: 130px;
  font-size: 1.375rem;
}
:fullscreen .route-dest,
:global(.fullscreen-mode) .route-dest {
  font-size: 1.0625rem;
}
:fullscreen .route-time,
:global(.fullscreen-mode) .route-time {
  min-width: 90px;
  font-size: 1.75rem;
}
:fullscreen .route-row,
:global(.fullscreen-mode) .route-row {
  padding-top: 10px;
  padding-bottom: 10px;
}
</style>
