<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { Icon } from '@iconify/vue'
import type { Exercise } from '~/stores/training'

const props = defineProps<{
  exercises: Exercise[]
}>()

const emit = defineEmits<{
  endTraining: []
}>()

// Camera state
const videoRef = ref<HTMLVideoElement | null>(null)
const stream = ref<MediaStream | null>(null)
const cameraError = ref<string | null>(null)
const isCameraReady = ref(false)

// Training state
const currentExerciseIndex = ref(0)
const currentSet = ref(1)
const currentReps = ref(0)
const isResting = ref(false)
const restTimeLeft = ref(0)
const showingResults = ref(false)

// Training stats
const totalReps = ref(0)
const accuracy = ref(0)
const startTime = ref<Date | null>(null)
const endTime = ref<Date | null>(null)

// Mock AI detection
const isDetectingMovement = ref(false)
const formQuality = ref(0) // 0-100

const currentExercise = computed(() => props.exercises[currentExerciseIndex.value])

const isExerciseComplete = computed(() => {
  if (!currentExercise.value) return false
  return currentSet.value > currentExercise.value.sets
})

const progress = computed(() => {
  const totalExercises = props.exercises.length
  const completed = currentExerciseIndex.value
  return Math.round((completed / totalExercises) * 100)
})

const elapsedTime = computed(() => {
  if (!startTime.value) return '0:00'
  const now = endTime.value || new Date()
  const diff = Math.floor((now.getTime() - startTime.value.getTime()) / 1000)
  const minutes = Math.floor(diff / 60)
  const seconds = diff % 60
  return `${minutes}:${seconds.toString().padStart(2, '0')}`
})

// Initialize camera
const initCamera = async () => {
  try {
    const mediaStream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'user', width: 1280, height: 720 },
      audio: false
    })

    stream.value = mediaStream

    if (videoRef.value) {
      videoRef.value.srcObject = mediaStream
      videoRef.value.onloadedmetadata = () => {
        videoRef.value?.play()
        isCameraReady.value = true
        startTime.value = new Date()
      }
    }
  } catch (error) {
    console.error('Camera error:', error)
    cameraError.value = 'Не удалось получить доступ к камере. Проверьте разрешения.'
  }
}

// Mock rep detection - симулирует определение повторений
const mockRepDetection = () => {
  if (isResting.value || showingResults.value) return

  // Случайное "определение" повторения каждые 2-3 секунды
  const interval = setInterval(() => {
    if (isResting.value || showingResults.value || !currentExercise.value) {
      clearInterval(interval)
      return
    }

    if (currentReps.value < currentExercise.value.reps) {
      currentReps.value++
      totalReps.value++

      // Симулируем качество формы (70-95%)
      formQuality.value = Math.floor(Math.random() * 25) + 70

      // Обновляем среднюю точность
      accuracy.value = Math.floor((accuracy.value * (totalReps.value - 1) + formQuality.value) / totalReps.value)

      // Анимация обнаружения
      isDetectingMovement.value = true
      setTimeout(() => {
        isDetectingMovement.value = false
      }, 500)
    } else {
      // Сет завершен
      clearInterval(interval)
      handleSetComplete()
    }
  }, 2500) // Одно повторение каждые 2.5 секунды
}

const handleSetComplete = () => {
  if (!currentExercise.value) return

  if (currentSet.value < currentExercise.value.sets) {
    // Переход к отдыху между сетами
    startRest(30) // 30 секунд отдыха
  } else {
    // Упражнение завершено, переход к следующему
    moveToNextExercise()
  }
}

const startRest = (seconds: number) => {
  isResting.value = true
  restTimeLeft.value = seconds

  const restInterval = setInterval(() => {
    restTimeLeft.value--

    if (restTimeLeft.value <= 0) {
      clearInterval(restInterval)
      isResting.value = false
      currentSet.value++
      currentReps.value = 0
      mockRepDetection() // Начинаем новый сет
    }
  }, 1000)
}

const moveToNextExercise = () => {
  if (currentExerciseIndex.value < props.exercises.length - 1) {
    // Переход к следующему упражнению
    currentExerciseIndex.value++
    currentSet.value = 1
    currentReps.value = 0

    // Отдых между упражнениями
    startRest(60) // 60 секунд отдыха
  } else {
    // Тренировка завершена
    completeWorkout()
  }
}

const completeWorkout = () => {
  endTime.value = new Date()
  showingResults.value = true

  // Останавливаем камеру
  if (stream.value) {
    stream.value.getTracks().forEach(track => track.stop())
  }
}

const skipRest = () => {
  if (isResting.value) {
    restTimeLeft.value = 0
  }
}

const exitTraining = () => {
  if (stream.value) {
    stream.value.getTracks().forEach(track => track.stop())
  }
  emit('endTraining')
}

onMounted(() => {
  initCamera()
  // Начинаем mock определение после инициализации камеры
  setTimeout(() => {
    if (isCameraReady.value) {
      mockRepDetection()
    }
  }, 2000)
})

onUnmounted(() => {
  if (stream.value) {
    stream.value.getTracks().forEach(track => track.stop())
  }
})
</script>

<template>
  <div class="fixed inset-0 bg-black z-50 flex flex-col">
    <!-- Camera View -->
    <div class="relative flex-1 overflow-hidden">
      <!-- Video Stream -->
      <video
        ref="videoRef"
        class="w-full h-full object-cover mirror"
        autoplay
        playsinline
        muted
      />

      <!-- Camera Error -->
      <div
        v-if="cameraError"
        class="absolute inset-0 flex items-center justify-center bg-black/80 p-6"
      >
        <div class="text-center">
          <Icon icon="heroicons:exclamation-triangle" class="text-6xl text-red-500 mx-auto mb-4" />
          <p class="text-white mb-4">{{ cameraError }}</p>
          <button
            @click="exitTraining"
            class="px-6 py-3 bg-neon text-black rounded-xl font-bold"
          >
            Вернуться назад
          </button>
        </div>
      </div>


      <!-- Top Controls -->
      <div class="absolute top-0 left-0 right-0 p-4 bg-gradient-to-b from-black/80 to-transparent">
        <div class="flex justify-between items-center">
          <button
            @click="exitTraining"
            class="w-10 h-10 rounded-full bg-black/50 backdrop-blur flex items-center justify-center text-white"
          >
            <Icon icon="heroicons:x-mark" class="text-xl" />
          </button>

          <div class="flex items-center gap-4">
            <!-- Timer -->
            <div class="px-4 py-2 rounded-full bg-black/50 backdrop-blur text-white font-mono">
              {{ elapsedTime }}
            </div>

            <!-- Set Progress -->
            <div v-if="!isResting && currentExercise" class="px-4 py-2 rounded-full bg-black/50 backdrop-blur text-white font-bold text-sm">
              Подход {{ currentSet }} из {{ currentExercise.sets }}
            </div>
          </div>
        </div>
      </div>

      <!-- Exercise Info -->
      <div
        v-if="!showingResults && currentExercise"
        class="absolute bottom-0 left-0 right-0 px-6 pt-8 pb-28 bg-gradient-to-t from-black via-black to-transparent"
      >
        <!-- Rest Mode -->
        <div v-if="isResting" class="text-center">
          <h2 class="text-2xl font-bold text-neon mb-3">Отдых</h2>
          <div class="text-7xl font-bold text-white mb-6 leading-none">{{ restTimeLeft }}<span class="text-4xl">s</span></div>
          <button
            @click="skipRest"
            class="px-8 py-3 bg-white/10 backdrop-blur text-white rounded-xl font-bold text-base"
          >
            Пропустить отдых
          </button>
        </div>

        <!-- Exercise Mode -->
        <div v-else>
          <div class="text-center">
            <h2 class="text-2xl font-bold text-white mb-4">{{ currentExercise.name }}</h2>

            <!-- Rep Counter -->
            <div class="text-7xl font-bold mb-4 leading-none">
              <span class="text-neon">{{ currentReps }}</span> <span class="text-white/40 text-5xl">/</span> <span class="text-white">{{ currentExercise.reps }}</span>
            </div>

            <!-- Form Quality -->
            <div class="flex items-center justify-center gap-3">
              <div class="w-40 h-2 bg-white/10 rounded-full overflow-hidden">
                <div
                  class="h-full bg-neon transition-all duration-300"
                  :style="{ width: `${formQuality}%` }"
                />
              </div>
              <span class="text-gray-400 text-sm font-medium">Форма: {{ formQuality }}%</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Results Screen -->
      <div
        v-if="showingResults"
        class="absolute inset-0 bg-black/95 backdrop-blur flex items-center justify-center p-6"
      >
        <div class="text-center max-w-sm w-full">
          <div class="w-20 h-20 rounded-full bg-neon/10 flex items-center justify-center mx-auto mb-6">
            <Icon icon="heroicons:trophy" class="text-5xl text-neon" />
          </div>

          <h1 class="text-4xl font-bold text-white mb-2">Отличная работа!</h1>
          <p class="text-gray-400 mb-8">Тренировка завершена</p>

          <!-- Stats Grid -->
          <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Время</p>
              <p class="text-2xl font-bold text-white">{{ elapsedTime }}</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Повторения</p>
              <p class="text-2xl font-bold text-neon">{{ totalReps }}</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Точность</p>
              <p class="text-2xl font-bold text-white">{{ accuracy }}%</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Калории</p>
              <p class="text-2xl font-bold text-white">~{{ Math.floor(totalReps * 0.5) }}</p>
            </div>
          </div>

          <button
            @click="exitTraining"
            class="w-full py-4 rounded-xl bg-neon text-black font-bold text-lg hover:brightness-110 active:scale-[0.98] transition-all"
          >
            Завершить тренировку
          </button>
        </div>
      </div>
    </div>
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

.bg-neon\/50 {
  background-color: rgba(204, 255, 0, 0.5);
}

.mirror {
  transform: scaleX(-1);
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes ping {
  75%, 100% {
    transform: translate(-50%, -50%) scale(2);
    opacity: 0;
  }
}

.animate-ping {
  animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;
}
</style>
