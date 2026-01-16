/**
 * Exercise counter with angle-based detection for workout tracking.
 * TypeScript port of the Python exercise_counter.py
 */

import type {
  ExerciseConfig,
  ExerciseStage,
  LegStages,
  PoseKeypoints
} from '~/types/pose';
import exercisesData from '~/data/exercises.json';

// Load exercise configurations - cast to proper type
const exercisesConfig = exercisesData as { exercises: Record<string, ExerciseConfig> };

export class ExerciseCounter {
  // Core counting variables
  private counter: number = 0;
  private stage: ExerciseStage = null;

  // Smoothing
  private smoothingWindow: number;
  private angleHistory: number[] = [];
  private lastCountTime: number = 0;
  private minRepTime: number = 500; // Minimum time between reps (milliseconds)

  // Form corrections
  private formCorrections: string[] = [];
  private lastAngle: number | null = null;

  // Exercise configurations
  private exerciseConfigs: Record<string, ExerciseConfig>;

  // Independent counting for leg exercises
  private legExercises: string[];
  private legStages: LegStages = { left: null, right: null };

  // Timed exercises (like plank)
  private timedExercises: string[];
  private isInPosition: boolean = false;

  constructor(smoothingWindow: number = 5) {
    this.smoothingWindow = smoothingWindow;
    this.exerciseConfigs = exercisesConfig.exercises;

    // Load leg exercises from config
    this.legExercises = Object.entries(this.exerciseConfigs)
      .filter(([_, config]) => config.is_leg_exercise)
      .map(([type]) => type);

    // Load timed exercises from config
    this.timedExercises = Object.entries(this.exerciseConfigs)
      .filter(([_, config]) => config.is_timed_exercise)
      .map(([type]) => type);
  }

  /**
   * Reset counter to initial state
   */
  resetCounter(): void {
    this.counter = 0;
    this.stage = null;
    this.angleHistory = [];
    this.legStages = { left: null, right: null };
    this.formCorrections = [];
    this.lastAngle = null;
    this.lastCountTime = 0;
    this.isInPosition = false;
  }

  /**
   * Calculate angle between three points
   */
  calculateAngle(
    a: number[] | undefined,
    b: number[] | undefined,
    c: number[] | undefined
  ): number | null {
    try {
      // Check for invalid points
      if (!a || !b || !c || a.length < 2 || b.length < 2 || c.length < 2) {
        return null;
      }

      const a0 = a[0] ?? 0;
      const a1 = a[1] ?? 0;
      const b0 = b[0] ?? 0;
      const b1 = b[1] ?? 0;
      const c0 = c[0] ?? 0;
      const c1 = c[1] ?? 0;

      if (
        isNaN(a0) || isNaN(a1) ||
        isNaN(b0) || isNaN(b1) ||
        isNaN(c0) || isNaN(c1) ||
        (a0 === 0 && a1 === 0) ||
        (b0 === 0 && b1 === 0) ||
        (c0 === 0 && c1 === 0)
      ) {
        return null;
      }

      // Calculate vectors
      const baX = a0 - b0;
      const baY = a1 - b1;
      const bcX = c0 - b0;
      const bcY = c1 - b1;

      // Calculate magnitudes
      const baNorm = Math.sqrt(baX * baX + baY * baY);
      const bcNorm = Math.sqrt(bcX * bcX + bcY * bcY);

      if (baNorm === 0 || bcNorm === 0) {
        return null;
      }

      // Calculate angle using dot product
      const dotProduct = baX * bcX + baY * bcY;
      let cosineAngle = dotProduct / (baNorm * bcNorm);

      // Clamp to prevent numerical errors
      cosineAngle = Math.max(-1, Math.min(1, cosineAngle));
      const angle = Math.acos(cosineAngle);

      return angle * (180 / Math.PI);
    } catch (error) {
      console.error('Angle calculation error:', error);
      return null;
    }
  }

  /**
   * Apply smoothing to reduce noise using median filter
   */
  smoothAngle(angle: number | null): number | null {
    if (angle === null) {
      return null;
    }

    this.angleHistory.push(angle);

    // Keep only the last N angles
    if (this.angleHistory.length > this.smoothingWindow) {
      this.angleHistory.shift();
    }

    if (this.angleHistory.length < 3) {
      return angle;
    }

    // Use median filter to remove outliers, then average
    const sorted = [...this.angleHistory].sort((a, b) => a - b);
    const medianAngle = sorted[Math.floor(sorted.length / 2)] ?? angle;

    // Calculate standard deviation
    const mean = this.angleHistory.reduce((a, b) => a + b, 0) / this.angleHistory.length;
    const stdDev = Math.sqrt(
      this.angleHistory.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) /
      this.angleHistory.length
    );

    // Filter outliers (angles > 2 std devs from median)
    const filteredAngles = this.angleHistory.filter(
      a => Math.abs(a - medianAngle) <= 2 * stdDev
    );

    if (filteredAngles.length === 0) {
      return angle;
    }

    return filteredAngles.reduce((a, b) => a + b, 0) / filteredAngles.length;
  }

  /**
   * Prevent counting reps too quickly
   */
  private checkRepTiming(): boolean {
    const currentTime = Date.now();
    if (currentTime - this.lastCountTime < this.minRepTime) {
      return false;
    }
    return true;
  }

  /**
   * Generic exercise counting function
   */
  countExercise(
    keypoints: PoseKeypoints,
    exerciseType: string
  ): number | null {
    try {
      const config = this.exerciseConfigs[exerciseType];
      if (!config) {
        console.warn(`Unknown exercise type: ${exerciseType}`);
        return null;
      }

      const kp = config.keypoints;

      // Validate keypoint indices exist
      if (kp.left.length < 3 || kp.right.length < 3) {
        return null;
      }

      const leftIdx0 = kp.left[0]!;
      const leftIdx1 = kp.left[1]!;
      const leftIdx2 = kp.left[2]!;
      const rightIdx0 = kp.right[0]!;
      const rightIdx1 = kp.right[1]!;
      const rightIdx2 = kp.right[2]!;

      // Calculate angles for both sides
      const leftAngle = this.calculateAngle(
        keypoints[leftIdx0] ?? undefined,
        keypoints[leftIdx1] ?? undefined,
        keypoints[leftIdx2] ?? undefined
      );

      const rightAngle = this.calculateAngle(
        keypoints[rightIdx0] ?? undefined,
        keypoints[rightIdx1] ?? undefined,
        keypoints[rightIdx2] ?? undefined
      );

      if (leftAngle === null || rightAngle === null) {
        return null;
      }

      // Handle leg exercises differently
      if (this.legExercises.includes(exerciseType)) {
        return this.countLegExercise(leftAngle, rightAngle, config);
      }

      // For other exercises, use average angle
      const avgAngle = (leftAngle + rightAngle) / 2;
      const smoothedAngle = this.smoothAngle(avgAngle);

      if (smoothedAngle === null) {
        return null;
      }

      // Get thresholds
      const upThreshold = config.up_angle;
      const downThreshold = config.down_angle;

      // Check form quality
      this.checkFormQuality(smoothedAngle, exerciseType, upThreshold, downThreshold);

      // Counting logic with timing check
      if (smoothedAngle > upThreshold) {
        this.stage = 'up';
      } else if (
        smoothedAngle < downThreshold &&
        this.stage === 'up' &&
        this.checkRepTiming()
      ) {
        this.stage = 'down';
        this.counter++;
        this.lastCountTime = Date.now();
      }

      return smoothedAngle;
    } catch (error) {
      console.error('Exercise counting error:', error);
      return null;
    }
  }

  /**
   * Count leg exercises with complete up-down cycles for each leg independently
   */
  private countLegExercise(
    leftAngle: number,
    rightAngle: number,
    config: ExerciseConfig
  ): number {
    const upThreshold = config.up_angle;
    const downThreshold = config.down_angle;

    if (this.checkRepTiming()) {
      // Left leg
      if (leftAngle > upThreshold) {
        this.legStages.left = 'up';
      } else if (
        leftAngle < downThreshold &&
        this.legStages.left === 'up'
      ) {
        this.counter++;
        this.lastCountTime = Date.now();
        this.legStages.left = 'down';
      }

      // Right leg
      if (rightAngle > upThreshold) {
        this.legStages.right = 'up';
      } else if (
        rightAngle < downThreshold &&
        this.legStages.right === 'up'
      ) {
        this.counter++;
        this.lastCountTime = Date.now();
        this.legStages.right = 'down';
      }
    }

    // Return average angle for display purposes
    return (leftAngle + rightAngle) / 2;
  }

  /**
   * Check form quality and add corrections if needed
   */
  private checkFormQuality(
    angle: number,
    exerciseType: string,
    upThreshold: number,
    downThreshold: number
  ): void {
    // Squat-specific corrections
    if (exerciseType === 'squat') {
      if (this.stage === 'down' && angle > downThreshold + 20) {
        this.formCorrections.push('Присядьте глубже - колени должны быть под углом 90°');
      } else if (this.stage === 'up' && angle < upThreshold - 10) {
        this.formCorrections.push('Полностью выпрямите ноги');
      }
    }
    // Pushup-specific corrections
    else if (exerciseType === 'pushup') {
      if (this.stage === 'down' && angle > downThreshold + 15) {
        this.formCorrections.push('Опуститесь ниже - грудь ближе к полу');
      } else if (this.stage === 'up' && angle < upThreshold - 15) {
        this.formCorrections.push('Полностью выпрямите руки');
      }
    }
    // Lunge-specific corrections
    else if (exerciseType === 'lunge') {
      if (this.stage === 'down' && angle > downThreshold + 20) {
        this.formCorrections.push('Опустите колено ниже - угол 90°');
      }
    }

    // General correction for insufficient range of motion
    if (this.lastAngle !== null) {
      const angleChange = Math.abs(angle - this.lastAngle);
      if (angleChange < 5 && this.stage !== null) {
        this.formCorrections.push('Увеличьте амплитуду движения');
      }
    }

    this.lastAngle = angle;
  }

  /**
   * Get current rep count
   */
  getCounter(): number {
    return this.counter;
  }

  /**
   * Get current exercise stage
   */
  getStage(): ExerciseStage {
    return this.stage;
  }

  /**
   * Return and reset form corrections
   */
  getFormCorrections(): string[] {
    const corrections = [...this.formCorrections];
    this.formCorrections = [];
    return corrections;
  }

  /**
   * Get exercise configuration
   */
  getExerciseConfig(exerciseType: string): ExerciseConfig | undefined {
    return this.exerciseConfigs[exerciseType];
  }

  /**
   * Check if exercise type exists
   */
  hasExercise(exerciseType: string): boolean {
    return exerciseType in this.exerciseConfigs;
  }

  /**
   * Check if exercise is a timed exercise (like plank)
   */
  isTimedExercise(exerciseType: string): boolean {
    return this.timedExercises.includes(exerciseType);
  }

  /**
   * Check if user is in correct position for timed exercise
   */
  getIsInPosition(): boolean {
    return this.isInPosition;
  }

  /**
   * Check timed exercise position (e.g., plank)
   * Returns the current angle if in position, null otherwise
   */
  checkTimedExercise(
    keypoints: PoseKeypoints,
    exerciseType: string
  ): { inPosition: boolean; angle: number | null } {
    const config = this.exerciseConfigs[exerciseType];
    if (!config) {
      return { inPosition: false, angle: null };
    }

    const kp = config.keypoints;

    // Validate keypoint indices exist
    if (kp.left.length < 3 || kp.right.length < 3) {
      return { inPosition: false, angle: null };
    }

    const leftIdx0 = kp.left[0]!;
    const leftIdx1 = kp.left[1]!;
    const leftIdx2 = kp.left[2]!;
    const rightIdx0 = kp.right[0]!;
    const rightIdx1 = kp.right[1]!;
    const rightIdx2 = kp.right[2]!;

    // Calculate angles for both sides
    const leftAngle = this.calculateAngle(
      keypoints[leftIdx0] ?? undefined,
      keypoints[leftIdx1] ?? undefined,
      keypoints[leftIdx2] ?? undefined
    );

    const rightAngle = this.calculateAngle(
      keypoints[rightIdx0] ?? undefined,
      keypoints[rightIdx1] ?? undefined,
      keypoints[rightIdx2] ?? undefined
    );

    if (leftAngle === null || rightAngle === null) {
      this.isInPosition = false;
      return { inPosition: false, angle: null };
    }

    const avgAngle = (leftAngle + rightAngle) / 2;
    const smoothedAngle = this.smoothAngle(avgAngle);

    if (smoothedAngle === null) {
      this.isInPosition = false;
      return { inPosition: false, angle: null };
    }

    // For plank: user should be in a straight position
    // Angle should be between down_angle and up_angle
    const inPosition = smoothedAngle >= config.down_angle && smoothedAngle <= config.up_angle;
    this.isInPosition = inPosition;

    // Add form correction if not in position
    if (!inPosition) {
      if (smoothedAngle < config.down_angle) {
        this.formCorrections.push('Выпрямите тело - не провисайте');
      } else if (smoothedAngle > config.up_angle) {
        this.formCorrections.push('Опустите бёдра - тело должно быть прямым');
      }
    }

    return { inPosition, angle: Math.round(smoothedAngle) };
  }
}
