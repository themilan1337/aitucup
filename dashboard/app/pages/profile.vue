<script setup lang="ts">
import { Icon } from '@iconify/vue'
import { computed } from 'vue'
import SectionTitle from '~/components/SectionTitle.vue'
import AchievementCard from '~/components/AchievementCard.vue'
import WorkoutHistoryCard from '~/components/WorkoutHistoryCard.vue'
import { useTrainingStore } from '~/stores/training'
import { useOnboardingStore } from '~/stores/onboarding'

const store = useTrainingStore()
const onboardingStore = useOnboardingStore()
const router = useRouter()

const unlockedAchievements = computed(() =>
  store.achievements.filter(a => a.unlocked).length
)

const handleReset = () => {
  store.resetOnboarding()
  onboardingStore.resetOnboarding()
  router.push('/onboarding')
}
</script>

<template>
  <div class="px-4 pt-12 pb-24">
    <h1 class="text-3xl font-bold mb-6">Профиль</h1>

    <!-- Profile Header -->
    <div class="flex flex-col items-center mb-6">
      <div class="w-32 h-32 rounded-full bg-[#424700] flex items-center justify-center text-neon mb-4">
        <Icon icon="heroicons:user" class="text-6xl" />
      </div>
      <h2 class="text-2xl font-bold mb-1">Пользователь</h2>
      <p class="text-gray-400 text-sm mb-4">С нами с января 2025</p>

      <button class="px-8 py-3 bg-neon text-black font-semibold rounded-xl hover:brightness-110 transition-all">
        Редактировать профиль
      </button>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-3 gap-4 mb-8 bg-[#1A1A1A] rounded-2xl p-4">
      <div class="flex flex-col items-center">
        <span class="text-3xl font-bold text-neon">{{ store.lifetimeStats.totalWorkouts }}</span>
        <span class="text-xs text-gray-400 mt-1">Тренировок</span>
      </div>
      <div class="flex flex-col items-center">
        <span class="text-3xl font-bold text-neon">{{ store.lifetimeStats.totalReps }}</span>
        <span class="text-xs text-gray-400 mt-1">Повторений</span>
      </div>
      <div class="flex flex-col items-center">
        <span class="text-3xl font-bold text-neon">{{ store.lifetimeStats.avgAccuracy }}%</span>
        <span class="text-xs text-gray-400 mt-1">Точность</span>
      </div>
    </div>

    <!-- Achievements Section -->
    <div class="mb-8">
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-2">
          <Icon icon="heroicons:trophy" class="text-neon text-xl" />
          <h3 class="text-lg font-semibold">Достижения</h3>
        </div>
        <span class="text-sm text-gray-400">{{ unlockedAchievements }}/{{ store.achievements.length }}</span>
      </div>

      <div class="grid grid-cols-3 gap-4">
        <AchievementCard
          v-for="achievement in store.achievements"
          :key="achievement.id"
          :name="achievement.name"
          :icon="achievement.icon"
          :unlocked="achievement.unlocked"
        />
      </div>
    </div>

    <!-- Recent Workouts Section -->
    <div class="mb-8">
      <div class="flex items-center gap-2 mb-4">
        <Icon icon="heroicons:clock" class="text-neon text-xl" />
        <h3 class="text-lg font-semibold">Последние тренировки</h3>
      </div>

      <WorkoutHistoryCard
        v-for="(workout, index) in store.workoutHistory"
        :key="index"
        :workout="workout"
      />
    </div>

    <!-- Settings Menu -->
    <div class="bg-[#1A1A1A] rounded-2xl overflow-hidden mb-4">
      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors border-b border-white/5">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:user-circle" class="text-neon text-xl" />
          <span class="text-white">Личные данные</span>
        </div>
        <Icon icon="heroicons:chevron-right" class="text-gray-500" />
      </button>

      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors border-b border-white/5">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:bell" class="text-neon text-xl" />
          <span class="text-white">Уведомления</span>
        </div>
        <Icon icon="heroicons:chevron-right" class="text-gray-500" />
      </button>

      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors border-b border-white/5">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:camera" class="text-neon text-xl" />
          <span class="text-white">Настройки камеры</span>
        </div>
        <Icon icon="heroicons:chevron-right" class="text-gray-500" />
      </button>

      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors border-b border-white/5">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:globe-alt" class="text-neon text-xl" />
          <span class="text-white">Язык</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-gray-400 text-sm">Русский</span>
          <Icon icon="heroicons:chevron-right" class="text-gray-500" />
        </div>
      </button>

      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors border-b border-white/5">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:question-mark-circle" class="text-neon text-xl" />
          <span class="text-white">Помощь и поддержка</span>
        </div>
        <Icon icon="heroicons:chevron-right" class="text-gray-500" />
      </button>

      <button class="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors">
        <div class="flex items-center gap-3">
          <Icon icon="heroicons:information-circle" class="text-neon text-xl" />
          <span class="text-white">О приложении</span>
        </div>
        <Icon icon="heroicons:chevron-right" class="text-gray-500" />
      </button>
    </div>

    <!-- Logout Button -->
    <button
      @click="handleReset"
      class="w-full bg-[#1A1A1A] text-red-500 py-4 rounded-2xl flex items-center justify-center gap-2 hover:bg-[#222] transition-colors"
    >
      <Icon icon="heroicons:arrow-left-on-rectangle" class="text-xl" />
      <span class="font-semibold">Выйти</span>
    </button>
  </div>
</template>

<style scoped>
.text-neon {
  color: var(--color-neon);
}
.bg-neon {
  background-color: var(--color-neon);
}
</style>
