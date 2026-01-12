import { defineStore } from 'pinia'

export const useOnboardingStore = defineStore('onboarding', () => {
  const goal = ref<string | null>(null)
  const level = ref<string | null>(null)
  const status = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
  const completed = ref(false)

  function setGoal(newGoal: string) {
    goal.value = newGoal
  }

  function setLevel(newLevel: string) {
    level.value = newLevel
  }

  function completeOnboarding() {
    completed.value = true
  }

  function resetOnboarding() {
    goal.value = null
    level.value = null
    completed.value = false
  }

  return {
    goal,
    level,
    status,
    completed,
    setGoal,
    setLevel,
    completeOnboarding,
    resetOnboarding
  }
}, {
  persist: true
})
