<script setup lang="ts">
import { Icon } from '@iconify/vue'
import FullScreenContainer from '~/components/ui/FullScreenContainer.vue'
import PrimaryButton from '~/components/ui/PrimaryButton.vue'
import SecondaryButton from '~/components/ui/SecondaryButton.vue'
import Confetti from '~/components/features/Confetti.vue'
import { useOnboardingStore } from '~/stores/onboarding'

const store = useOnboardingStore()
const confettiRef = ref<InstanceType<typeof Confetti> | null>(null)

onMounted(() => {
  // Mark onboarding as completed
  store.completeOnboarding()
  
  // Trigger confetti after a short delay
  setTimeout(() => {
    confettiRef.value?.fire()
  }, 500)
})

const handleStartWorkout = () => {
  console.log('Starting workout...')
}

const handleViewPlan = () => {
  console.log('Viewing plan...')
}
</script>

<template>
  <FullScreenContainer>
    <Confetti ref="confettiRef" />
    
    <div class="flex-1 flex flex-col items-center justify-center text-center">
      <div class="w-24 h-24 rounded-full bg-[#1A1A1A] border-2 border-[#CCFF00] flex items-center justify-center mb-8 shadow-[0_0_30px_rgba(204,255,0,0.2)]">
        <Icon icon="hugeicons:tick-02" class="text-[#CCFF00] text-5xl" />
      </div>

      <h1 class="text-3xl font-bold mb-4">Ваш план готов</h1>
      <p class="text-gray-400 max-w-[280px]">
        Начните первую тренировку и отслеживайте прогресс каждый день
      </p>
    </div>
    
    <div class="mt-8 space-y-4">
      <PrimaryButton 
        icon="hugeicons:play"
        @click="handleStartWorkout"
      >
        Начать тренировку
      </PrimaryButton>
      
      <SecondaryButton 
        @click="handleViewPlan"
      >
        Посмотреть план
      </SecondaryButton>
    </div>
  </FullScreenContainer>
</template>

