<script setup lang="ts">
import { Icon } from '@iconify/vue'
import FullScreenContainer from '~/components/ui/FullScreenContainer.vue'
import OnboardingStepHeader from '~/components/ui/OnboardingStepHeader.vue'
import PrimaryButton from '~/components/ui/PrimaryButton.vue'

const router = useRouter()

const handleStart = () => {
  router.push('/onboarding/how-it-works')
}
</script>

<template>
  <FullScreenContainer>
    <OnboardingStepHeader :current-step="3" :total-steps="4" />
    
    <div class="mt-4 flex-1 flex flex-col items-center justify-center text-center">
      <div class="relative w-full aspect-square mb-12 flex items-center justify-center">
        <!-- Placeholder for athlete photo -->
        <div class="absolute inset-0 bg-gradient-to-b from-transparent to-black z-10" />
        <div class="w-full h-full rounded-full bg-[#CCFF00] opacity-20 blur-3xl absolute scale-75" />
        <Icon icon="hugeicons:yoga-02" class="text-[12rem] text-[#CCFF00] relative z-20" />
      </div>

      <h1 class="text-3xl font-bold mb-4">Тренируйтесь правильно с помощью ИИ</h1>
      <p class="text-gray-400">
        MuscleUp Vision анализирует технику упражнений через камеру и помогает выполнять тренировки безопасно и эффективно.
      </p>
    </div>
    
    <div class="mt-8">
      <PrimaryButton 
        icon="hugeicons:arrow-right-02"
        @click="handleStart"
      >
        Начать
      </PrimaryButton>
    </div>
  </FullScreenContainer>
</template>

