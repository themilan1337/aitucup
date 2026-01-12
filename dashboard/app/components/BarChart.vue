<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  data: number[] // e.g. [1, 1, 0, 1...] 1 for trained, 0 for not
}>()

const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']

// ensure data matches 7 days
const chartData = computed(() => {
    // Fill/slice to exactly 7
    return [...props.data, ...Array(7).fill(0)].slice(0, 7)
})

</script>

<template>
  <div class="w-full bg-card rounded-2xl p-4">
    <div class="grid grid-cols-7 gap-2 h-40 items-end">
       <div 
         v-for="(trained, index) in chartData" 
         :key="index"
         class="flex flex-col items-center gap-2 h-full justify-end"
       >
          <!-- Bar -->
          <div 
            class="w-full rounded-t-sm transition-all duration-500 ease-out"
            :class="trained ? 'bg-neon shadow-[0_0_10px_rgba(204,255,0,0.3)]' : 'bg-[#1A1A1A]'"
            :style="{ height: trained ? '100%' : '10%' }"
          ></div>
          
          <!-- Label -->
          <span class="text-[10px] text-gray-500 font-medium">{{ days[index] }}</span>
       </div>
    </div>
  </div>
</template>

<style scoped>
.bg-card {
  background-color: var(--color-card);
}
.bg-neon {
  background-color: var(--color-neon);
}
</style>
