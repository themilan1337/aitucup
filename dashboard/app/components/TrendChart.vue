<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  data: number[]
  labels?: string[]
  height?: number
  min?: number
  max?: number
}>()

const chartHeight = props.height || 150
const chartWidth = 300 // localized coordinate system

const normalizedPoints = computed(() => {
  if (!props.data.length) return ''
  
  const minVal = props.min ?? Math.min(...props.data) * 0.9
  const maxVal = props.max ?? Math.max(...props.data) * 1.1
  const range = maxVal - minVal || 1
  
  return props.data.map((val, index) => {
    const x = (index / (props.data.length - 1)) * chartWidth
    const y = chartHeight - ((val - minVal) / range) * chartHeight
    return `${x},${y}`
  }).join(' ')
})

const pointsArray = computed(() => {
    if (!props.data.length) return []
     const minVal = props.min ?? Math.min(...props.data) * 0.9
     const maxVal = props.max ?? Math.max(...props.data) * 1.1
    const range = maxVal - minVal || 1

    return props.data.map((val, index) => {
        const x = (index / (props.data.length - 1)) * chartWidth
        const y = chartHeight - ((val - minVal) / range) * chartHeight
        return { x, y, val }
    })
})

</script>

<template>
  <div class="w-full relative select-none">
     
     <!-- Chart Container -->
    <svg :viewBox="`0 0 ${chartWidth} ${chartHeight}`" class="w-full h-full overflow-visible">
       <!-- Gradient Defs -->
       <defs>
         <linearGradient id="lineGap" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stop-color="var(--color-neon)" stop-opacity="0.2"/>
            <stop offset="100%" stop-color="var(--color-neon)" stop-opacity="0"/>
         </linearGradient>
       </defs>
       
       <!-- Guide line (optional, e.g. avg) -->
       <line 
         :x1="0" 
         :x2="chartWidth" 
         :y1="chartHeight / 2" 
         :y2="chartHeight / 2" 
         stroke="#333" 
         stroke-width="1" 
         stroke-dasharray="4 4"
        />

       <!-- The Trend Line -->
       <polyline
         :points="normalizedPoints"
         fill="none"
         stroke="var(--color-neon)"
         stroke-width="3"
         stroke-linecap="round"
         stroke-linejoin="round"
         class="drop-shadow-[0_0_10px_rgba(204,255,0,0.3)]"
       />

       <!-- Dots -->
       <circle
         v-for="(point, i) in pointsArray"
         :key="i"
         :cx="point.x"
         :cy="point.y"
         r="3"
         fill="var(--color-bg)"
         stroke="var(--color-neon)"
         stroke-width="2"
       />
    </svg>

    <!-- Legend/Labels -->
    <div v-if="labels" class="flex justify-between mt-4 text-xs text-gray-500">
        <span v-for="(label, i) in labels" :key="i">{{ label }}</span>
    </div>
  </div>
</template>

<style scoped>
</style>
