<script setup lang="ts">
import FullScreenContainer from '~/components/ui/FullScreenContainer.vue'
import OnboardingStepHeader from '~/components/ui/OnboardingStepHeader.vue'
import PrimaryButton from '~/components/ui/PrimaryButton.vue'
import { Icon } from '@iconify/vue'

const router = useRouter()

const steps = [
  { id: 1, icon: 'hugeicons:camera-01', title: 'Камера определяет положение тела', text: 'Используя технологию компьютерного зрения' },
  { id: 2, icon: 'hugeicons:brain-02', title: 'ИИ анализирует технику', text: 'Нейросеть оценивает правильность выполнения' },
  { id: 3, icon: 'hugeicons:notification-03', title: 'Приложение подсказывает, если форма нарушена', text: 'Получайте мгновенную обратную связь' }
]

const handleContinue = () => {
  router.push('/dashboard')
}
</script>

<template>
  <FullScreenContainer>
    <OnboardingStepHeader :current-step="4" :total-steps="4" />
    
    <div class="mt-4 flex-1">
      <h1 class="text-3xl font-bold mb-2">Как работает MuscleUp Vision</h1>
      <p class="text-gray-400 mb-8">Технология компьютерного зрения для идеальной техники</p>
      
      <div class="space-y-6">
        <div 
          v-for="step in steps" 
          :key="step.id"
          class="flex items-start gap-4 p-4 bg-[#1A1A1A] rounded-2xl"
        >
          <div class="w-10 h-10 rounded-xl bg-[#CCFF00] flex items-center justify-center text-black font-bold text-xl shrink-0">
            {{ step.id }}
          </div>
          <div class="flex-1">
            <div class="flex items-center gap-2 mb-1">
              <Icon :icon="step.icon" class="text-[#CCFF00] text-xl" />
              <h3 class="font-bold">{{ step.title }}</h3>
            </div>
            <p class="text-sm text-gray-400">{{ step.text }}</p>
          </div>
        </div>
      </div>
    </div>
    
    <div class="mt-8">
      <PrimaryButton 
        icon="hugeicons:arrow-right-02"
        @click="handleContinue"
      >
        Продолжить
      </PrimaryButton>
    </div>
  </FullScreenContainer>
</template>
