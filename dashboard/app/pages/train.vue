<script setup lang="ts">
import { ref } from 'vue'
import { useTrainingStore } from '~/stores/training'
import { Icon } from '@iconify/vue'
import SectionTitle from '~/components/SectionTitle.vue'
import ExerciseCard from '~/components/ExerciseCard.vue'
import WorkoutCamera from '~/components/workout/WorkoutCamera.vue'

const store = useTrainingStore()
const isTrainingStarted = ref(false)

// Mock data для тренировки
const todayDuration = 15 // min
const muscleGroupTarget = "Ноги"

const startTraining = () => {
  isTrainingStarted.value = true
}

const endTraining = () => {
  isTrainingStarted.value = false
}
</script>

<template>
  <div class="min-h-screen bg-black pb-20">
    <!-- Если тренировка не начата - показываем план -->
    <div v-if="!isTrainingStarted" class="px-4 pt-12 pb-8">
      <header class="flex justify-between items-start mb-6">
        <div>
          <p class="text-gray-400 text-sm mb-1">Готовы к тренировке?</p>
          <h1 class="text-3xl font-bold">Начнем!</h1>
        </div>
      </header>

      <!-- Today's Training Plan -->
      <div class="mb-8">
        <div class="bg-[#111] rounded-3xl p-5">
          <!-- Exercises List -->
          <div class="mb-4 border border-white/5 rounded-xl">
            <ExerciseCard
              v-for="exercise in store.todayExercises"
              :key="exercise.id"
              :name="exercise.name"
              :sets="exercise.sets"
              :reps="exercise.reps"
              icon="heroicons:bolt"
            />
          </div>

          <!-- Metadata -->
          <div class="flex justify-between items-center text-sm text-gray-400 px-1 mb-6">
            <div class="flex items-center gap-2">
              <Icon icon="heroicons:clock" class="text-neon" />
              <span>{{ todayDuration }} мин</span>
            </div>
            <div class="flex items-center gap-2">
              <Icon icon="heroicons:stop" class="text-neon" />
              <span>{{ muscleGroupTarget }}</span>
            </div>
          </div>

          <!-- Start Training Button -->
          <button
            @click="startTraining"
            class="w-full py-4 rounded-xl bg-neon text-black font-bold text-lg flex items-center justify-center gap-2 hover:brightness-110 active:scale-[0.98] transition-all"
          >
            Начать тренировку
          </button>
        </div>
      </div>

      <!-- Training Tips -->
      <div class="bg-[#111] rounded-2xl p-5">
        <h3 class="text-white font-bold mb-3 flex items-center gap-2">
          <Icon icon="heroicons:light-bulb" class="text-neon text-xl" />
          Советы перед началом
        </h3>
        <ul class="space-y-2 text-sm text-gray-400">
          <li class="flex items-start gap-2">
            <Icon icon="heroicons:check-circle" class="text-neon mt-0.5 flex-shrink-0" />
            <span>Убедитесь, что камера видит вас полностью</span>
          </li>
          <li class="flex items-start gap-2">
            <Icon icon="heroicons:check-circle" class="text-neon mt-0.5 flex-shrink-0" />
            <span>Выберите хорошо освещенное место</span>
          </li>
          <li class="flex items-start gap-2">
            <Icon icon="heroicons:check-circle" class="text-neon mt-0.5 flex-shrink-0" />
            <span>Держите телефон в вертикальном положении</span>
          </li>
        </ul>
      </div>
    </div>

    <!-- Если тренировка начата - показываем камеру -->
    <WorkoutCamera
      v-else
      :exercises="store.todayExercises"
      @end-training="endTraining"
    />
  </div>
</template>

<style scoped>
.text-neon {
  color: var(--color-neon);
}
.bg-neon {
  background-color: var(--color-neon);
}
.bg-neon\/10 {
  background-color: rgba(204, 255, 0, 0.1);
}
</style>
