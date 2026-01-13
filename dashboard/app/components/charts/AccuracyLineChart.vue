<script setup lang="ts">
import { computed } from 'vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler
} from 'chart.js'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler
)

const props = defineProps<{
  data: number[]
}>()

const chartData = computed(() => ({
  labels: props.data.map((_, i) => ''),
  datasets: [
    {
      data: props.data,
      borderColor: '#CCFF00',
      backgroundColor: (context: any) => {
        const ctx = context.chart.ctx
        const gradient = ctx.createLinearGradient(0, 0, 0, 256)
        gradient.addColorStop(0, 'rgba(204, 255, 0, 0.2)')
        gradient.addColorStop(1, 'rgba(204, 255, 0, 0)')
        return gradient
      },
      borderWidth: 3,
      fill: true,
      tension: 0.4,
      pointRadius: 4,
      pointBackgroundColor: '#CCFF00',
      pointBorderColor: '#000',
      pointBorderWidth: 2,
      pointHoverRadius: 6,
      pointHoverBackgroundColor: '#CCFF00',
      pointHoverBorderColor: '#000',
      pointHoverBorderWidth: 2,
    }
  ]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    },
    tooltip: {
      enabled: true,
      backgroundColor: '#1A1A1A',
      titleColor: '#CCFF00',
      bodyColor: '#fff',
      borderColor: '#CCFF00',
      borderWidth: 1,
      padding: 12,
      displayColors: false,
      callbacks: {
        label: function(context: any) {
          return context.parsed.y + '%'
        },
        title: function() {
          return 'Точность'
        }
      }
    }
  },
  scales: {
    y: {
      beginAtZero: false,
      min: 75,
      max: 95,
      grid: {
        color: '#2A2A2A',
        drawBorder: false
      },
      ticks: {
        color: '#666',
        font: {
          size: 11,
          family: 'Product Sans, sans-serif'
        },
        callback: function(value: any) {
          return value + '%'
        }
      },
      border: {
        display: false
      }
    },
    x: {
      grid: {
        display: false
      },
      ticks: {
        display: false
      },
      border: {
        display: false
      }
    }
  },
  interaction: {
    intersect: false,
    mode: 'index' as const
  }
}
</script>

<template>
  <div style="height: 100%;">
    <Line :data="chartData" :options="chartOptions" />
  </div>
</template>
