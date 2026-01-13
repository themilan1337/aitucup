<script setup lang="ts">
import { Icon } from '@iconify/vue'
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const isActive = (path: string) => route.path === path || (path !== '/' && route.path.startsWith(path))

const navItems = [
  { name: 'Главная', path: '/home', icon: 'hugeicons:home-01' },
  { name: 'Прогресс', path: '/progress', icon: 'hugeicons:chart-03' },
  { name: 'Тренировка', path: '/train', icon: 'hugeicons:flash', isCenter: true },
  { name: 'План', path: '/plan', icon: 'hugeicons:calendar-04' },
  { name: 'Профиль', path: '/profile', icon: 'hugeicons:user' },
]
</script>

<template>
  <div class="fixed bottom-0 left-0 w-full bg-black/90 backdrop-blur-md border-t border-white/10 pb-safe pt-2 z-50">
    <div class="flex justify-between items-end px-2 max-w-md mx-auto">
      <router-link
        v-for="item in navItems"
        :key="item.path"
        :to="item.path"
        class="flex flex-col items-center justify-center transition-all duration-300 relative group"
        :class="[
          item.isCenter ? '-top-5' : 'py-2 flex-1'
        ]"
      >
        <!-- Center Floating Button -->
        <div 
          v-if="item.isCenter"
          class="w-14 h-14 rounded-full bg-neon flex items-center justify-center shadow-[0_0_20px_rgba(204,255,0,0.4)] mb-2"
        >
           <Icon :icon="item.icon" class="text-black text-2xl" />
        </div>

        <!-- Normal Nav Item -->
        <template v-else>
          <div 
            class="mb-1 transition-colors duration-300"
            :class="isActive(item.path) ? 'text-neon' : 'text-gray-500 group-hover:text-gray-300'"
          >
            <Icon :icon="item.icon" class="text-2xl" />
          </div>
          <span 
            class="text-[10px] font-medium transition-colors duration-300"
            :class="isActive(item.path) ? 'text-neon' : 'text-gray-500 group-hover:text-gray-300'"
          >
            {{ item.name }}
          </span>
          
          <!-- Active Indicator Dot (Optional, generic style) -->
          <!-- <div class="absolute -bottom-2 w-1 h-1 bg-neon rounded-full" v-if="isActive(item.path)" /> -->
        </template>
      </router-link>
    </div>
  </div>
</template>

<style scoped>
.pb-safe {
  padding-bottom: env(safe-area-inset-bottom, 20px);
}
.bg-neon {
  background-color: var(--color-neon);
}
.text-neon {
  color: var(--color-neon);
}
</style>
