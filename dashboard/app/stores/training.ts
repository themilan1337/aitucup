import { defineStore } from 'pinia'

export interface Exercise {
  id: string
  name: string
  sets: number
  reps: number
  duration?: number // in minutes
  muscleGroup?: string
  completed: boolean
}

export interface TrainingStoreState {
  streak: number
  todayExercises: Exercise[]
  weeklyStats: {
    workouts: number
    calories: number
    minutes: number
  }
  lifetimeStats: {
    totalWorkouts: number
    totalReps: number
    avgAccuracy: number
    bestStreak: number
  }
  progressData: {
    accuracyTrend: number[]
    weeklyFrequency: number[]
  }
  records: {
    squats: number
    lunges: number
    pushups: number
    plank: number // seconds
  }
}

export const useTrainingStore = defineStore('training', {
  state: (): TrainingStoreState => ({
    streak: 19,
    todayExercises: [
      { id: '1', name: 'Приседания', sets: 3, reps: 20, muscleGroup: 'Ноги', completed: false },
      { id: '2', name: 'Выпады', sets: 3, reps: 15, muscleGroup: 'Ноги', completed: false },
    ],
    weeklyStats: {
      workouts: 4,
      calories: 111,
      minutes: 50,
    },
    lifetimeStats: {
      totalWorkouts: 19,
      totalReps: 908,
      avgAccuracy: 86,
      bestStreak: 3,
    },
    progressData: {
      // Mock data points for the trend chart
      accuracyTrend: [82, 85, 83, 86, 88, 87, 86, 89, 90, 88, 87, 86, 88, 89],
      // Mock data for weekly bar chart (Mon-Sun)
      weeklyFrequency: [1, 1, 1, 0, 1, 0, 0], // 1 = trained, 0 = rest
    },
    records: {
      squats: 28,
      lunges: 40,
      pushups: 22,
      plank: 1, // '1 сек' in screenshot? likely placeholder, but keeping type consistent
    },
  }),
  actions: {
    toggleExerciseCompletion(id: string) {
      const ex = this.todayExercises.find((e) => e.id === id)
      if (ex) {
        ex.completed = !ex.completed
      }
    },
    resetOnboarding() {
        // Dummy action for profile
        this.streak = 0
    }
  },
  persist: true,
})
