/**
 * MediaPipe Pose Composable
 * Provides pose detection using MediaPipe Pose JS running locally in the browser.
 * No WebSocket required - all processing happens on the client.
 */

import { ref, shallowRef, onUnmounted } from 'vue';
import type {
  PoseKeypoints,
  ExerciseStage,
  MediaPipePoseResults,
  ExerciseConfig
} from '~/types/pose';
import { mediaPipeToCoco, getAnglePointCoords } from '~/utils/keypointMapping';
import { ExerciseCounter } from '~/utils/exerciseCounter';

// MediaPipe CDN URLs
const MEDIAPIPE_POSE_CDN = 'https://cdn.jsdelivr.net/npm/@mediapipe/pose@0.5.1675469404/pose.js';
const MEDIAPIPE_CAMERA_CDN = 'https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils@0.3.1675466862/camera_utils.js';

// Declare global types for MediaPipe
declare global {
  interface Window {
    Pose: any;
    Camera: any;
  }
}

export interface UseMediaPipeOptions {
  smoothingWindow?: number;
  targetFps?: number;
}

export const useMediaPipe = (options: UseMediaPipeOptions = {}) => {
  const { smoothingWindow = 5, targetFps = 15 } = options;

  // State
  const isLoading = ref(true);
  const isReady = ref(false);
  const error = ref<string | null>(null);

  // Pose detection results
  const keypoints = shallowRef<PoseKeypoints | null>(null);
  const anglePoint = shallowRef<number[][] | null>(null);
  const currentAngle = ref<number | null>(null);
  const reps = ref(0);
  const stage = ref<ExerciseStage>(null);
  const formCorrections = ref<string[]>([]);

  // Timed exercise state (e.g., plank)
  const isInPosition = ref(false);

  // Internal state
  let pose: any = null;
  let exerciseCounter: ExerciseCounter | null = null;
  let currentExerciseType = '';
  let lastFrameTime = 0;
  const frameInterval = 1000 / targetFps;

  // Video dimensions for coordinate scaling
  let videoWidth = 1280;
  let videoHeight = 720;

  /**
   * Load MediaPipe scripts from CDN
   */
  const loadScript = (src: string): Promise<void> => {
    return new Promise((resolve, reject) => {
      // Check if already loaded
      if (document.querySelector(`script[src="${src}"]`)) {
        resolve();
        return;
      }

      const script = document.createElement('script');
      script.src = src;
      script.crossOrigin = 'anonymous';
      script.onload = () => resolve();
      script.onerror = () => reject(new Error(`Failed to load script: ${src}`));
      document.head.appendChild(script);
    });
  };

  /**
   * Initialize MediaPipe Pose
   */
  const initialize = async (): Promise<void> => {
    try {
      isLoading.value = true;
      error.value = null;

      // Load MediaPipe scripts
      await loadScript(MEDIAPIPE_POSE_CDN);

      // Wait for Pose to be available
      await new Promise<void>((resolve, reject) => {
        let attempts = 0;
        const checkPose = () => {
          if (window.Pose) {
            resolve();
          } else if (attempts > 50) {
            reject(new Error('MediaPipe Pose not available after timeout'));
          } else {
            attempts++;
            setTimeout(checkPose, 100);
          }
        };
        checkPose();
      });

      // Initialize Pose
      pose = new window.Pose({
        locateFile: (file: string) => {
          return `https://cdn.jsdelivr.net/npm/@mediapipe/pose@0.5.1675469404/${file}`;
        }
      });

      // Configure pose detection
      pose.setOptions({
        modelComplexity: 1, // 0=lite, 1=full, 2=heavy
        smoothLandmarks: true,
        enableSegmentation: false,
        smoothSegmentation: false,
        minDetectionConfidence: 0.5,
        minTrackingConfidence: 0.5
      });

      // Set up results callback
      pose.onResults(handlePoseResults);

      // Initialize exercise counter
      exerciseCounter = new ExerciseCounter(smoothingWindow);

      isLoading.value = false;
      isReady.value = true;
      console.log('MediaPipe Pose initialized successfully');
    } catch (err) {
      console.error('Failed to initialize MediaPipe:', err);
      error.value = err instanceof Error ? err.message : 'Failed to initialize MediaPipe';
      isLoading.value = false;
    }
  };

  /**
   * Handle pose detection results
   */
  const handlePoseResults = (results: MediaPipePoseResults): void => {
    if (!results.poseLandmarks || !exerciseCounter) {
      keypoints.value = null;
      return;
    }

    // Convert MediaPipe landmarks to COCO format
    const cocoKeypoints = mediaPipeToCoco(
      results.poseLandmarks,
      videoWidth,
      videoHeight
    );

    keypoints.value = cocoKeypoints;

    // Count exercise if exercise type is set
    if (currentExerciseType && exerciseCounter.hasExercise(currentExerciseType)) {
      // Check if this is a timed exercise (like plank)
      if (exerciseCounter.isTimedExercise(currentExerciseType)) {
        // For timed exercises, check if user is in position
        const result = exerciseCounter.checkTimedExercise(cocoKeypoints, currentExerciseType);
        isInPosition.value = result.inPosition;

        if (result.angle !== null) {
          currentAngle.value = result.angle;
        }

        // Get form corrections
        const corrections = exerciseCounter.getFormCorrections();
        if (corrections.length > 0) {
          formCorrections.value = corrections;
        }
      } else {
        // For regular exercises, count reps
        const angle = exerciseCounter.countExercise(cocoKeypoints, currentExerciseType);

        if (angle !== null) {
          currentAngle.value = Math.round(angle);
        }

        // Update state from counter
        reps.value = exerciseCounter.getCounter();
        stage.value = exerciseCounter.getStage();

        // Get form corrections
        const corrections = exerciseCounter.getFormCorrections();
        if (corrections.length > 0) {
          formCorrections.value = corrections;
        }
      }

      // Get angle point for visualization
      const config = exerciseCounter.getExerciseConfig(currentExerciseType);
      if (config && config.angle_point) {
        anglePoint.value = getAnglePointCoords(cocoKeypoints, config.angle_point);
      }
    }
  };

  /**
   * Process a video frame
   * Should be called in requestAnimationFrame loop
   */
  const processFrame = async (
    video: HTMLVideoElement,
    exerciseType: string
  ): Promise<void> => {
    if (!isReady.value || !pose) {
      return;
    }

    // Rate limiting
    const now = performance.now();
    if (now - lastFrameTime < frameInterval) {
      return;
    }
    lastFrameTime = now;

    // Update exercise type if changed
    if (exerciseType !== currentExerciseType) {
      currentExerciseType = exerciseType;
    }

    // Update video dimensions
    videoWidth = video.videoWidth || 1280;
    videoHeight = video.videoHeight || 720;

    try {
      await pose.send({ image: video });
    } catch (err) {
      console.error('Error processing frame:', err);
    }
  };

  /**
   * Reset the exercise counter
   */
  const resetCounter = (): void => {
    if (exerciseCounter) {
      exerciseCounter.resetCounter();
    }
    reps.value = 0;
    stage.value = null;
    currentAngle.value = null;
    formCorrections.value = [];
    anglePoint.value = null;
    isInPosition.value = false;
  };

  /**
   * Check if exercise is timed (like plank)
   */
  const isTimedExercise = (exerciseType: string): boolean => {
    return exerciseCounter?.isTimedExercise(exerciseType) ?? false;
  };

  /**
   * Set the current exercise type
   */
  const setExerciseType = (exerciseType: string): void => {
    currentExerciseType = exerciseType;
  };

  /**
   * Get exercise configuration
   */
  const getExerciseConfig = (exerciseType: string): ExerciseConfig | undefined => {
    return exerciseCounter?.getExerciseConfig(exerciseType);
  };

  /**
   * Cleanup resources
   */
  const cleanup = (): void => {
    if (pose) {
      pose.close();
      pose = null;
    }
    exerciseCounter = null;
    isReady.value = false;
  };

  // Auto cleanup on unmount
  onUnmounted(() => {
    cleanup();
  });

  return {
    // State
    isLoading,
    isReady,
    error,

    // Pose detection results
    keypoints,
    anglePoint,
    currentAngle,
    reps,
    stage,
    formCorrections,

    // Timed exercise state
    isInPosition,

    // Methods
    initialize,
    processFrame,
    resetCounter,
    setExerciseType,
    getExerciseConfig,
    isTimedExercise,
    cleanup
  };
};
