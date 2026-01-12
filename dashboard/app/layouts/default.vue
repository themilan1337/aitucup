<script setup lang="ts">
import BottomNav from '~/components/BottomNav.vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const showNav = computed(() => !route.path.includes('onboarding'))
</script>

<template>
  <div class="bg-black min-h-screen text-white pb-24">
    <div class="max-w-md mx-auto min-h-screen relative">
       <slot />
    </div>
    <BottomNav v-if="showNav" />
  </div>
</template>
