<script setup lang="ts">
const props = defineProps<{
  data: number[]
}>()

const daysOfWeek = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']

const isActiveDay = (index: number) => {
  return props.data[index] > 0
}
</script>

<template>
  <div class="bg-[#1A1A1A] rounded-2xl p-6">
    <div class="flex justify-between items-center gap-3">
      <div
        v-for="(day, index) in daysOfWeek"
        :key="day"
        class="flex flex-col items-center gap-3 flex-1"
      >
        <!-- Indicator Circle -->
        <div
          class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300"
          :class="isActiveDay(index)
            ? 'bg-[#CCFF00] shadow-[0_0_20px_rgba(204,255,0,0.4)]'
            : 'bg-[#2A2A2A]'"
        >
          <!-- Checkmark Icon for active days -->
          <svg
            v-if="isActiveDay(index)"
            class="w-5 h-5 text-black"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="3"
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>

        <!-- Day Label -->
        <span
          class="text-sm transition-colors duration-300"
          :class="isActiveDay(index) ? 'text-[#CCFF00] font-medium' : 'text-[#666]'"
        >
          {{ day }}
        </span>
      </div>
    </div>
  </div>
</template>
