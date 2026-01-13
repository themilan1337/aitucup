<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  name: string
  icon: string
  unlocked: boolean
}>()
</script>

<template>
  <div class="flex flex-col items-center gap-2 min-w-[80px]">
    <div
      class="w-16 h-16 rounded-full flex items-center justify-center transition-all"
      :class="unlocked ? 'bg-neon/20 text-neon' : 'bg-white/5 text-gray-600'"
    >
      <Icon :icon="icon" class="text-2xl" />
    </div>
    <span
      class="text-xs text-center leading-tight px-1"
      :class="unlocked ? 'text-white' : 'text-gray-600'"
    >
      {{ name }}
    </span>
  </div>
</template>

<style scoped>
.bg-neon {
  background-color: var(--color-neon);
}
.text-neon {
  color: var(--color-neon);
}
</style>
