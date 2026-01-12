<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  name: string
  sets: number
  reps: number
  icon?: string
}>()
</script>

<template>
  <div class="flex items-center justify-between py-3 px-4 bg-card rounded-xl mb-2 items-center">
    <div class="flex items-center gap-3">
       <div class="w-8 h-8 rounded-full bg-[#1A1A1A] flex items-center justify-center text-neon">
         <Icon :icon="icon || 'heroicons:bolt'" class="text-xl" />
       </div>
       <span class="font-medium text-white">{{ name }}</span>
    </div>
    
    <div class="text-gray-400 font-medium">
      {{ sets }} <span class="text-gray-600 text-xs mx-1">x</span> {{ reps }}
    </div>
  </div>
</template>

<style scoped>
.bg-card {
  background-color: var(--color-card);
}
.text-neon {
  color: var(--color-neon);
}
</style>
