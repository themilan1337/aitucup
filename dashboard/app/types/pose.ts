/**
 * TypeScript types for pose detection and exercise counting
 */

// Keypoint from MediaPipe Pose
export interface Keypoint {
  x: number;
  y: number;
  z?: number;
  visibility?: number;
}

// COCO 17 keypoints format (used by exercise counter)
export type PoseKeypoints = number[][];

// Exercise configuration from exercises.json
export interface ExerciseConfig {
  name_ru: string;
  name_en: string;
  down_angle: number;
  up_angle: number;
  keypoints: {
    left: number[];
    right: number[];
  };
  is_leg_exercise: boolean;
  is_timed_exercise?: boolean;
  angle_point: number[];
}

// All exercises configuration
export interface ExercisesConfig {
  exercises: Record<string, ExerciseConfig>;
}

// Exercise stage during counting
export type ExerciseStage = 'up' | 'down' | null;

// Leg stages for leg exercises
export interface LegStages {
  left: ExerciseStage;
  right: ExerciseStage;
}

// Exercise counter state
export interface ExerciseCounterState {
  counter: number;
  stage: ExerciseStage;
  legStages: LegStages;
  angleHistory: number[];
  lastCountTime: number;
  lastAngle: number | null;
  formCorrections: string[];
}

// Pose detection result from MediaPipe
export interface PoseDetectionResult {
  keypoints: PoseKeypoints;
  angle: number | null;
  anglePoint: number[][] | null;
  reps: number;
  stage: ExerciseStage;
  formCorrections: string[];
}

// MediaPipe Pose landmark result
export interface MediaPipeLandmark {
  x: number;
  y: number;
  z: number;
  visibility: number;
}

// MediaPipe Pose results
export interface MediaPipePoseResults {
  poseLandmarks?: MediaPipeLandmark[];
  poseWorldLandmarks?: MediaPipeLandmark[];
}
