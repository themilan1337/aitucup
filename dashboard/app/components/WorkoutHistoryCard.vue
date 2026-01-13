<script setup lang="ts">
import { Icon } from '@iconify/vue'
import type { WorkoutHistory } from '~/stores/training'

defineProps<{
  workout: WorkoutHistory
}>()
</script>

<template>
  <div class="bg-[#1A1A1A] rounded-2xl p-4 mb-4 border border-white/5">
    <!-- Date Header -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-white">{{ workout.date }}</h3>
      <div v-if="workout.completed" class="w-6 h-6 rounded-full bg-neon/20 flex items-center justify-center">
        <Icon icon="heroicons:check" class="text-neon text-sm" />
      </div>
    </div>

    <!-- Exercises List -->
    <div class="space-y-3 mb-4">
      <div
        v-for="(exercise, index) in workout.exercises"
        :key="index"
        class="flex items-center justify-between text-white"
      >
        <div class="flex items-center gap-3">
          <Icon :icon="exercise.icon" class="text-neon text-xl" />
          <span class="text-sm">{{ exercise.name }}</span>
        </div>
        <span class="text-sm text-gray-400">{{ exercise.reps }} повт</span>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="flex items-center justify-between pt-3 border-t border-white/5">
      <div class="flex items-center gap-4 text-sm">
        <div class="flex items-center gap-1.5 text-neon">
          <Icon icon="heroicons:fire" class="text-base" />
          <span class="text-white">{{ workout.calories }} ккал</span>
        </div>
        <div class="flex items-center gap-1.5 text-neon">
          <Icon icon="heroicons:clock" class="text-base" />
          <span class="text-white">{{ workout.duration }}</span>
        </div>
        <div class="flex items-center gap-1.5 text-neon">
          <Icon icon="heroicons:check-badge" class="text-base" />
          <span class="text-white">{{ workout.accuracy }} %</span>
        </div>
      </div>
    </div>
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
