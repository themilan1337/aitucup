<script setup lang="ts">
import { ref } from 'vue'
import { Icon } from '@iconify/vue'
import { useTrainingStore } from '~/stores/training'
import SectionTitle from '~/components/SectionTitle.vue'
import BarChart from '~/components/BarChart.vue'
import TrendChart from '~/components/TrendChart.vue'

const store = useTrainingStore()

const tabs = ['Неделя', 'Месяц', 'Всё время']
const activeTab = ref('Неделя')

// Helper for records
const recordsList = [
  { name: 'Приседания', value: store.records.squats, unit: 'повт', icon: 'heroicons:bolt' },
  { name: 'Выпады', value: store.records.lunges, unit: 'повт', icon: 'heroicons:fire' }, // using fire as substitute for walking figure if needed
  { name: 'Отжимания', value: store.records.pushups, unit: 'повт', icon: 'heroicons:user' }, // using user as substitute for pushup
  { name: 'Планка', value: store.records.plank, unit: 'сек', icon: 'heroicons:clock' },
]

// Mock data for sparklines
const mockTrend = [50, 40, 60, 55, 70, 65, 80]
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
              <Icon icon="heroicons:view-columns" class="text-neon" />
              <span>Тренировок</span>
           </div>
           <p class="text-3xl font-bold">{{ store.lifetimeStats.totalWorkouts }}</p>
        </div>

        <!-- Reps (with sparkline) -->
        <div class="bg-card p-4 rounded-2xl bg-[#111] relative overflow-hidden">
           <div class="relative z-10">
             <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
                <Icon icon="heroicons:arrow-trending-up" class="text-neon" />
                <span>Повторений</span>
             </div>
             <p class="text-3xl font-bold">{{ store.lifetimeStats.totalReps }}</p>
           </div>
           <div class="absolute bottom-0 left-0 right-0 h-10 opacity-50">
              <TrendChart :data="mockTrend" :height="40" />
           </div>
        </div>

        <!-- Time -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <Icon icon="heroicons:clock" class="text-blue-500" />
              <span>Время</span>
           </div>
           <p class="text-3xl font-bold">{{ store.weeklyStats.minutes }} <span class="text-lg font-normal text-gray-500">мин</span></p>
        </div>

        <!-- Calories (with sparkline) -->
        <div class="bg-card p-4 rounded-2xl bg-[#111] relative overflow-hidden">
           <div class="relative z-10">
              <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
                 <Icon icon="heroicons:fire" class="text-orange-500" />
                 <span>Калорий</span>
              </div>
              <p class="text-3xl font-bold">{{ store.weeklyStats.calories }} <span class="text-lg font-normal text-gray-500">ккал</span></p>
           </div>
           <div class="absolute bottom-0 left-0 right-0 h-10 opacity-50">
               <!-- Use different color trend if possible, but neon is default -->
               <TrendChart :data="[30,40,35,50,45,60]" :height="40" />
           </div>
        </div>
        
        <!-- Accuracy -->
        <div class="bg-card p-4 rounded-2xl bg-[#111] relative overflow-hidden">
            <div class="relative z-10">
               <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
                  <Icon icon="heroicons:check-badge" class="text-green-500" />
                  <span>Точность формы</span>
               </div>
               <p class="text-3xl font-bold">{{ store.lifetimeStats.avgAccuracy }}<span class="text-lg font-normal text-gray-500">%</span></p>
            </div>
             <div class="absolute bottom-0 left-0 right-0 h-10 opacity-50">
               <TrendChart :data="store.progressData.accuracyTrend.slice(-7)" :height="40" />
           </div>
        </div>

          <!-- Weight -->
        <div class="bg-card p-4 rounded-2xl bg-[#111]">
           <div class="flex items-center gap-2 mb-2 text-gray-400 text-sm">
              <Icon icon="heroicons:scale" class="text-purple-500" />
              <span>Вес</span>
           </div>
           <p class="text-3xl font-bold">70.0 <span class="text-lg font-normal text-gray-500">кг</span></p>
        </div>
     </div>

     <!-- Charts -->
     <div class="mb-8">
        <SectionTitle title="Частота тренировок" />
        <BarChart :data="store.progressData.weeklyFrequency" />
     </div>

     <div class="mb-8">
        <SectionTitle title="Динамика точности формы" />
        <div class="bg-card p-4 rounded-2xl bg-[#111] h-64 flex flex-col">
            <TrendChart :data="store.progressData.accuracyTrend" :height="200" />
            <div class="flex justify-between mt-auto pt-4 text-xs">
                <div class="flex items-center gap-1 text-gray-400"><span class="w-2 h-2 rounded-full bg-green-500"></span>Отлично (>90%)</div>
                <div class="flex items-center gap-1 text-gray-400"><span class="w-2 h-2 rounded-full bg-orange-500"></span>Хорошо (80-90%)</div>
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
