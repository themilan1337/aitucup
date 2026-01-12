<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  label: string
  value: string | number
  subtext?: string
  icon?: string
  iconColor?: string
}>()
</script>

<template>
  <div class="bg-card hover:bg-card-hover rounded-2xl p-4 transition-colors duration-200">
    <!-- Header: Icon + Label -->
    <div class="flex items-center gap-2 mb-2">
       <div v-if="icon" 
            class="w-8 h-8 rounded-full flex items-center justify-center bg-white/5"
            :class="iconColor || 'text-neon'"
       >
         <Icon :icon="icon" />
       </div>
       <span class="text-gray-400 text-sm font-medium">{{ label }}</span>
    </div>
    
    <!-- Value -->
    <div class="flex items-baseline gap-1">
      <h3 class="text-2xl font-bold text-white tracking-tight">{{ value }}</h3>
      <span v-if="subtext" class="text-sm text-gray-500">{{ subtext }}</span>
    </div>
  </div>
</template>

<style scoped>
.bg-card {
  background-color: var(--color-card);
}
.bg-card-hover {
    background-color: var(--color-card-hover);
}
.text-neon {
  color: var(--color-neon);
}
</style>
