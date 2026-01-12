<script setup lang="ts">
import SectionTitle from '~/components/SectionTitle.vue'
import ExerciseCard from '~/components/ExerciseCard.vue'
import { Icon } from '@iconify/vue'

const weekDays = [
    { day: 'Пн', active: true, status: 'done' },
    { day: 'Вт', active: false, status: 'missed' },
    { day: 'Ср', active: false, status: 'today' },
    { day: 'Чт', active: false, status: 'future' },
    { day: 'Пт', active: false, status: 'future' },
    { day: 'Сб', active: false, status: 'rest' },
    { day: 'Вс', active: false, status: 'rest' },
]

// Mock plan
const exercises = [
    { name: 'Приседания', sets: 3, reps: 20, icon: 'heroicons:bolt' },
    { name: 'Выпады', sets: 3, reps: 15, icon: 'heroicons:fire' },
    { name: 'Планка', sets: 2, reps: 60, icon: 'heroicons:clock' },
]
</script>

<template>
  <div class="px-4 pt-12 pb-8">
     <h1 class="text-3xl font-bold mb-6">План тренировок</h1>

     <!-- Calendar Strip -->
     <div class="flex justify-between mb-8 bg-[#111] p-3 rounded-2xl">
        <div 
          v-for="(d, i) in weekDays" 
          :key="i"
          class="flex flex-col items-center gap-2"
        >
           <span class="text-xs text-gray-400">{{ d.day }}</span>
           <div 
             class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-all"
             :class="[
                d.status === 'today' ? 'bg-neon text-black' : 
                d.status === 'done' ? 'bg-white/10 text-white' : 
                'bg-transparent text-gray-600'
             ]"
           >
              <Icon v-if="d.status === 'done'" icon="heroicons:check" />
              <span v-else>{{ i + 12 }}</span> <!-- Mock date -->
           </div>
        </div>
     </div>

     <!-- Today's Plan -->
     <div class="mb-8">
        <SectionTitle title="Сегодня" subtitle="Ноги и ягодицы" />
        
        <div class="space-y-2">
            <ExerciseCard 
                v-for="ex in exercises" 
                :key="ex.name"
                v-bind="ex"
            />
        </div>

        <button class="w-full mt-6 py-4 rounded-xl bg-neon text-black font-bold flex items-center justify-center gap-2">
            Начать
        </button>
     </div>
  </div>
</template>

<style scoped>
.bg-neon { background-color: var(--color-neon); }
</style>
