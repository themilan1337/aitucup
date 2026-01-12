<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  disabled?: boolean
  icon?: string
}>()

defineEmits<{
  (e: 'click'): void
}>()
</script>

<template>
  <button
    :disabled="disabled"
    class="w-full h-14 bg-transparent border-2 border-[#CCFF00] text-[#CCFF00] font-bold rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-95 disabled:opacity-30 disabled:active:scale-100 cursor-pointer"
    @click="$emit('click')"
  >
    <slot />
    <Icon v-if="icon" :icon="icon" class="text-xl" />
  </button>
</template>
