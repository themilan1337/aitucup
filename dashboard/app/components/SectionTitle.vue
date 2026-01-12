<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
  rightText?: string
}>()
</script>

<template>
  <div class="flex items-end justify-between mb-4 px-1">
    <div>
      <h2 class="text-xl font-bold text-white">{{ title }}</h2>
      <p v-if="subtitle" class="text-sm text-gray-400 mt-0.5">{{ subtitle }}</p>
    </div>
    <div v-if="rightText" class="text-sm text-gray-500 font-medium mb-1">
      {{ rightText }}
    </div>
  </div>
</template>
