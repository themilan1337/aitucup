<script setup lang="ts">
import { Icon } from '@iconify/vue'
import SectionTitle from '~/components/SectionTitle.vue'
import { useTrainingStore } from '~/stores/training'
import { useOnboardingStore } from '~/stores/onboarding'

const store = useTrainingStore()
const onboardingStore = useOnboardingStore()
const router = useRouter()

const handleReset = () => {
  store.resetOnboarding() // Resets stats
  onboardingStore.resetOnboarding() // Resets flow status
  router.push('/onboarding')
}
</script>

<template>
  <div class="px-4 pt-12 pb-8">
    <SectionTitle title="Профиль" />

    <div class="flex flex-col items-center mb-8">
       <div class="w-24 h-24 rounded-full bg-[#1A1A1A] flex items-center justify-center text-neon border border-white/10 mb-4">
           <Icon icon="heroicons:user" class="text-4xl" />
       </div>
       <h2 class="text-2xl font-bold">User Name</h2>
       <p class="text-gray-400">Начинающий</p>
    </div>

    <div class="space-y-4">
       <button class="w-full flex items-center justify-between bg-[#111] p-4 rounded-xl hover:bg-[#1A1A1A]">
          <span class="text-white">Редактировать профиль</span>
          <Icon icon="heroicons:chevron-right" class="text-gray-500" />
       </button>
       
        <button class="w-full flex items-center justify-between bg-[#111] p-4 rounded-xl hover:bg-[#1A1A1A]">
          <span class="text-white">Настройки уведомлений</span>
          <Icon icon="heroicons:chevron-right" class="text-gray-500" />
       </button>
       
       <button @click="handleReset" class="w-full flex items-center justify-between bg-[#111] p-4 rounded-xl hover:bg-[#1A1A1A] text-red-500">
          <span>Сбросить данные</span>
          <Icon icon="heroicons:trash" />
       </button>
    </div>
  </div>
</template>

<style scoped>
.text-neon { color: var(--color-neon); }
</style>
