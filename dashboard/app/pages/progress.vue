<script setup lang="ts">
import { ref } from 'vue'
import { Icon } from '@iconify/vue'
import { useTrainingStore } from '~/stores/training'
import SectionTitle from '~/components/SectionTitle.vue'
import WeeklyBarChart from '~/components/charts/WeeklyBarChart.vue'
import AccuracyLineChart from '~/components/charts/AccuracyLineChart.vue'

const store = useTrainingStore()

const tabs = ['Неделя', 'Месяц', 'Всё время']
const activeTab = ref('Неделя')

// Helper for records
const recordsList = [
  { name: 'Приседания', value: store.records.squats, unit: 'повт', icon: 'heroicons:bolt' },
  { name: 'Выпады', value: store.records.lunges, unit: 'повт', icon: 'heroicons:fire' },
  { name: 'Отжимания', value: store.records.pushups, unit: 'повт', icon: 'heroicons:user' },
  { name: 'Планка', value: store.records.plank, unit: 'сек', icon: 'heroicons:clock' },
]
</script>

<template>
  <div class="px-4 pt-12 pb-8">
     <!-- Header -->
     <h1 class="text-3xl font-bold mb-6">Прогресс</h1>

     <!-- Tabs -->
     <div class="flex p-1 bg-[#1A1A1A] rounded-2xl mb-8">
        <button
          v-for="tab in tabs"
          :key="tab"
          @click="activeTab = tab"
          class="flex-1 py-2 text-sm font-medium rounded-xl transition-all duration-200"
          :class="activeTab === tab ? 'bg-neon text-black' : 'text-gray-400 hover:text-white'"
        >
          {{ tab }}
        </button>
     </div>

     <!-- Main Stats Grid -->
     <div class="grid grid-cols-2 gap-4 mb-8">
        <!-- Workouts -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Тренировок</span>
           </div>
           <p class="text-3xl font-bold">{{ store.lifetimeStats.totalWorkouts }}</p>
        </div>

        <!-- Reps -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Повторений</span>
           </div>
           <p class="text-3xl font-bold">{{ store.lifetimeStats.totalReps }}</p>
        </div>

        <!-- Time -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Время</span>
           </div>
           <p class="text-3xl font-bold">{{ store.weeklyStats.minutes }} <span class="text-lg font-normal text-gray-500">мин</span></p>
        </div>

        <!-- Calories -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Калорий</span>
           </div>
           <p class="text-3xl font-bold">{{ store.weeklyStats.calories }} <span class="text-lg font-normal text-gray-500">ккал</span></p>
        </div>
        
        <!-- Accuracy -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Точность формы</span>
           </div>
           <p class="text-3xl font-bold">{{ store.lifetimeStats.avgAccuracy }}<span class="text-lg font-normal text-gray-500">%</span></p>
        </div>

          <!-- Weight -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <span>Вес</span>
           </div>
           <p class="text-3xl font-bold">70.0 <span class="text-lg font-normal text-gray-500">кг</span></p>
        </div>
     </div>

     <!-- Charts -->
     <div class="mb-8">
        <SectionTitle title="Частота тренировок" />
        <WeeklyBarChart :data="store.progressData.weeklyFrequency" />
     </div>

     <div class="mb-8">
        <SectionTitle title="Динамика точности формы" />
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
            <div class="h-64 mb-4">
              <AccuracyLineChart :data="store.progressData.accuracyTrend" />
            </div>
            <div class="flex justify-center gap-6 text-sm">
                <div class="flex items-center gap-2 text-gray-400">
                  <span class="w-3 h-3 rounded-full bg-green-500"></span>
                  <span>Отлично (&gt;90%)</span>
                </div>
                <div class="flex items-center gap-2 text-gray-400">
                  <span class="w-3 h-3 rounded-full bg-orange-500"></span>
                  <span>Хорошо (80-90%)</span>
                </div>
            </div>
        </div>
     </div>

     <!-- Records -->
     <div class="mb-24">
        <SectionTitle title="Личные рекорды" icon="heroicons:trophy" />
        <div class="bg-[#111] rounded-2xl p-4">
             <div 
               v-for="(rec, i) in recordsList" 
               :key="rec.name"
               class="flex items-center justify-between py-3 border-b border-white/5 last:border-0"
             >
                <div class="flex items-center gap-3">
                   <Icon :icon="rec.icon" class="text-neon text-xl" />
                   <span class="text-white">{{ rec.name }}</span>
                </div>
                <div class="font-bold text-xl">
                   <span class="text-neon">{{ rec.value }}</span> 
                   <span class="text-sm text-gray-500 font-normal ml-1">{{ rec.unit }}</span>
                </div>
             </div>
        </div>
     </div>

  </div>
</template>

<style scoped>
.bg-neon { background-color: var(--color-neon); }
.text-neon { color: var(--color-neon); }
</style>
