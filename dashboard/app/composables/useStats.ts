/**
 * Stats API Composable
 * Provides methods to fetch user statistics and progress data
 */

export interface DashboardStats {
  total_workouts: number
  total_reps: number
  total_minutes: number
  total_calories: number
  average_accuracy: number
  current_streak: number
  streak_text: string
}

export interface AccuracyTrendPoint {
  date: string
  accuracy: number
}

export interface PersonalRecords {
  squat: number
  lunge: number
  pushup: number
  situp: number
  crunch: number
  bicep_curl: number
  lateral_raise: number
  overhead_press: number
  leg_raise: number
  knee_raise: number
  knee_press: number
  plank: number // duration in seconds
}

export type TimePeriod = 'week' | 'month' | 'all'

export const useStats = () => {
  const { get } = useApi()

  /**
   * Get dashboard statistics with optional time period filter
   */
  const getDashboardStats = async (period: TimePeriod = 'all'): Promise<DashboardStats> => {
    return await get<DashboardStats>(`/api/v1/stats/dashboard?period=${period}`)
  }

  /**
   * Get form accuracy trend for the last N days
   */
  const getAccuracyTrend = async (days: number = 7): Promise<AccuracyTrendPoint[]> => {
    return await get<AccuracyTrendPoint[]>(`/api/v1/stats/accuracy-trend?days=${days}`)
  }

  /**
   * Get personal records (max reps/duration) for each exercise
   */
  const getPersonalRecords = async (): Promise<PersonalRecords> => {
    return await get<PersonalRecords>('/api/v1/stats/personal-records')
  }

  /**
   * Get workout frequency for current week (Mon-Sun)
   * Returns array of 7 booleans
   */
  const getWeeklyFrequency = async (): Promise<boolean[]> => {
    return await get<boolean[]>('/api/v1/stats/weekly-frequency')
  }

  return {
    getDashboardStats,
    getAccuracyTrend,
    getPersonalRecords,
    getWeeklyFrequency,
  }
}
