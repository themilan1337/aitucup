<script setup lang="ts">
import FullScreenContainer from '~/components/ui/FullScreenContainer.vue'
import OnboardingStepHeader from '~/components/ui/OnboardingStepHeader.vue'
import SelectableCard from '~/components/ui/SelectableCard.vue'
import PrimaryButton from '~/components/ui/PrimaryButton.vue'
import { useOnboardingStore } from '~/stores/onboarding'

const store = useOnboardingStore()
const router = useRouter()

const levels = [
  { id: 'beginner', title: 'Начальный', description: 'Только начинаю', icon: 'hugeicons:star' },
  { id: 'intermediate', title: 'Средний', description: 'Занимаюсь регулярно', icon: 'hugeicons:star-face' },
  { id: 'advanced', title: 'Продвинутый', description: 'Опытный спортсмен', icon: 'hugeicons:stars' }
]

const selectLevel = (id: string) => {
  store.setLevel(id)
}

const handleContinue = () => {
  if (store.level) {
    router.push('/onboarding/vision')
  }
}
</script>

<template>
  <FullScreenContainer>
    <OnboardingStepHeader :current-step="2" :total-steps="4" />
    
    <div class="mt-4 flex-1">
      <h1 class="text-3xl font-bold mb-2">Ваш уровень подготовки</h1>
      <p class="text-gray-400 mb-8">Это поможет подобрать оптимальную нагрузку</p>
      
      <div class="space-y-4">
        <SelectableCard
          v-for="level in levels"
          :key="level.id"
          :title="level.title"
          :description="level.description"
          :icon="level.icon"
          :selected="store.level === level.id"
          @click="selectLevel(level.id)"
        />
      </div>
    </div>
    
    <div class="mt-8">
      <PrimaryButton 
        :disabled="!store.level"
        icon="hugeicons:arrow-right-02"
        @click="handleContinue"
      >
        Продолжить
      </PrimaryButton>
    </div>
  </FullScreenContainer>
</template>
