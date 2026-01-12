<script setup lang="ts">
import FullScreenContainer from '~/components/ui/FullScreenContainer.vue'
import OnboardingStepHeader from '~/components/ui/OnboardingStepHeader.vue'
import SelectableCard from '~/components/ui/SelectableCard.vue'
import PrimaryButton from '~/components/ui/PrimaryButton.vue'
import { useOnboardingStore } from '~/stores/onboarding'

const store = useOnboardingStore()
const router = useRouter()

const goals = [
  { id: 'lose-weight', title: 'Похудеть', icon: 'hugeicons:fire' },
  { id: 'tone-body', title: 'Привести тело в тонус', icon: 'hugeicons:body-armor' },
  { id: 'improve-fitness', title: 'Улучшить физическую форму', icon: 'hugeicons:favourite' }
]

const selectGoal = (id: string) => {
  store.setGoal(id)
}

const handleContinue = () => {
  if (store.goal) {
    router.push('/onboarding/level')
  }
}
</script>

<template>
  <FullScreenContainer>
    <OnboardingStepHeader :current-step="1" :total-steps="4" />
    
    <div class="mt-4 flex-1">
      <h1 class="text-3xl font-bold mb-2">Какая у вас цель?</h1>
      <p class="text-gray-400 mb-8">Выберите основную цель тренировок</p>
      
      <div class="space-y-4">
        <SelectableCard
          v-for="goal in goals"
          :key="goal.id"
          :title="goal.title"
          :icon="goal.icon"
          :selected="store.goal === goal.id"
          @click="selectGoal(goal.id)"
        />
      </div>
    </div>
    
    <div class="mt-8">
      <PrimaryButton 
        :disabled="!store.goal"
        icon="hugeicons:arrow-right-02"
        @click="handleContinue"
      >
        Продолжить
      </PrimaryButton>
    </div>
  </FullScreenContainer>
</template>
