import { useOnboardingStore } from '../stores/onboarding'

export default defineNuxtRouteMiddleware((to) => {
  const store = useOnboardingStore()

  // If completed and trying to access onboarding, redirect to home
  if (store.completed && to.path.startsWith('/onboarding')) {
    return navigateTo('/home')
  }

  // If NOT completed and trying to access home, redirect to onboarding start
  if (!store.completed && (to.path === '/home' || to.path === '/dashboard')) {
    return navigateTo('/onboarding/')
  }
  
  // If at root, redirect to onboarding or home
  if (to.path === '/') {
    return store.completed ? navigateTo('/home') : navigateTo('/onboarding/')
  }
})
