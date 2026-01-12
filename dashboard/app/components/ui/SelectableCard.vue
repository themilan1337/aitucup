<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  title: string
  description?: string
  selected?: boolean
  icon: string
}>()

defineEmits<{
  (e: 'click'): void
}>()
</script>

<template>
  <button
    class="relative w-full p-4 bg-[#1A1A1A] rounded-2xl border-2 transition-all text-left flex items-center gap-4 cursor-pointer"
    :class="[
      selected ? 'border-[#CCFF00] shadow-[0_0_15px_rgba(204,255,0,0.3)]' : 'border-transparent'
    ]"
    @click="$emit('click')"
  >
    <div class="w-12 h-12 rounded-full bg-[#2A2A2A] flex items-center justify-center">
      <Icon :icon="icon" class="text-2xl" :class="selected ? 'text-[#CCFF00]' : 'text-gray-400'" />
    </div>
    
    <div class="flex-1">
      <h3 class="text-lg font-bold">{{ title }}</h3>
      <p v-if="description" class="text-sm text-gray-400">{{ description }}</p>
    </div>

    <Icon 
      v-if="selected" 
      icon="hugeicons:tick-02" 
      class="text-[#CCFF00] text-2xl"
    />
  </button>
</template>
