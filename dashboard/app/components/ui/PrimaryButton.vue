<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  disabled?: boolean
  loading?: boolean
  icon?: string
}>()

defineEmits<{
  (e: 'click'): void
}>()
</script>

<template>
  <button
    :disabled="disabled || loading"
    class="w-full h-14 bg-[#CCFF00] text-black font-bold rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-95 disabled:opacity-30 disabled:active:scale-100 cursor-pointer"
    @click="$emit('click')"
  >
    <Icon v-if="loading" icon="line-md:loading-twotone-loop" class="text-2xl" />
    <template v-else>
      <slot />
      <Icon v-if="icon" :icon="icon" class="text-xl" />
    </template>
  </button>
</template>
