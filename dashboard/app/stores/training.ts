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

export interface WorkoutExercise {
  name: string
  reps: number
  icon: string
}

export interface WorkoutHistory {
  date: string // e.g., '11 января'
  exercises: WorkoutExercise[]
  calories: number
  duration: string // e.g., '4:09'
  accuracy: number
  completed: boolean
}

export interface Achievement {
  id: string
  name: string
  icon: string
  unlocked: boolean
  description?: string
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
  workoutHistory: WorkoutHistory[]
  achievements: Achievement[]
}

export const useTrainingStore = defineStore('training', {
  state: (): TrainingStoreState => ({
    streak: 0,
    todayExercises: [],
    weeklyStats: {
      workouts: 0,
      calories: 0,
      minutes: 0,
    },
    lifetimeStats: {
      totalWorkouts: 0,
      totalReps: 0,
      avgAccuracy: 0,
      bestStreak: 0,
    },
    progressData: {
      accuracyTrend: [],
      weeklyFrequency: [],
    },
    records: {
      squats: 0,
      lunges: 0,
      pushups: 0,
      plank: 0,
    },
    workoutHistory: [],
    achievements: [],
  }),
  actions: {
    toggleExerciseCompletion(id: string) {
      const ex = this.todayExercises.find((e) => e.id === id)
      if (ex) {
        ex.completed = !ex.completed
      }
    },

    /**
     * Load statistics for a specific time period
     * Note: Only 'week' and 'all' periods update the store state
     * The 'month' period data is returned but not stored
     */
    async loadStats(period: 'week' | 'month' | 'all' = 'all') {
      try {
        const { getDashboardStats } = useStats()
        const stats = await getDashboardStats(period)

        if (period === 'week') {
          this.weeklyStats = {
            workouts: stats.total_workouts,
            calories: stats.total_calories,
            minutes: stats.total_minutes,
          }
        } else if (period === 'all') {
          this.lifetimeStats = {
            totalWorkouts: stats.total_workouts,
            totalReps: stats.total_reps,
            avgAccuracy: Math.round(stats.average_accuracy * 100),
            bestStreak: stats.current_streak,
          }
          this.streak = stats.current_streak
        }
        // 'month' period is only used for display in progress.vue,
        // not stored in state

        return stats
      } catch (error) {
        console.error('Failed to load stats:', error)
        throw error
      }
    },

    /**
     * Load personal records
     */
    async loadPersonalRecords() {
      try {
        const { getPersonalRecords } = useStats()
        const records = await getPersonalRecords()

        this.records = {
          squats: records.squat,
          lunges: records.lunge,
          pushups: records.pushup,
          plank: records.plank,
        }

        return records
      } catch (error) {
        console.error('Failed to load personal records:', error)
        throw error
      }
    },

    /**
     * Load accuracy trend data
     */
    async loadAccuracyTrend(days: number = 14) {
      try {
        const { getAccuracyTrend } = useStats()
        const trend = await getAccuracyTrend(days)

        // Convert to percentage array
        this.progressData.accuracyTrend = trend.map(point =>
          Math.round(point.accuracy * 100)
        )

        return trend
      } catch (error) {
        console.error('Failed to load accuracy trend:', error)
        throw error
      }
    },

    /**
     * Load weekly workout frequency
     */
    async loadWeeklyFrequency() {
      try {
        const { getWeeklyFrequency } = useStats()
        const frequency = await getWeeklyFrequency()

        // Convert boolean array to number array (1 = trained, 0 = rest)
        this.progressData.weeklyFrequency = frequency.map(trained => trained ? 1 : 0)

        return frequency
      } catch (error) {
        console.error('Failed to load weekly frequency:', error)
        throw error
      }
    },

    /**
     * Load all statistics data
     */
    async loadAllStats() {
      try {
        await Promise.all([
          this.loadStats('week'),
          this.loadStats('all'),
          this.loadPersonalRecords(),
          this.loadAccuracyTrend(14),
          this.loadWeeklyFrequency(),
        ])
      } catch (error) {
        console.error('Failed to load all stats:', error)
        throw error
      }
    }
  },
  persist: true,
})
