<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from "vue";
import { Icon } from "@iconify/vue";
import confetti from "canvas-confetti";
import type { Exercise } from "~/stores/training";

const props = defineProps<{
  exercises: Exercise[];
  planDayId?: string;
}>();

const emit = defineEmits<{
  endTraining: [];
}>();

// Camera state
const videoRef = ref<HTMLVideoElement | null>(null);
const canvasRef = ref<HTMLCanvasElement | null>(null);
const stream = ref<MediaStream | null>(null);
const cameraError = ref<string | null>(null);
const isCameraReady = ref(false);

// Video dimensions for scaling
const videoIntrinsicWidth = ref(1280);
const videoIntrinsicHeight = ref(720);

// MediaPipe Pose (local detection)
const {
  isLoading: mediaPipeLoading,
  isReady: mediaPipeReady,
  error: mediaPipeError,
  keypoints,
  anglePoint,
  currentAngle,
  reps: detectedReps,
  formCorrections,
  isInPosition,
  initialize: initializeMediaPipe,
  processFrame,
  resetCounter: resetMediaPipeCounter,
  isTimedExercise,
} = useMediaPipe({ targetFps: 15 });

// Training state
const currentExerciseIndex = ref(0);
const currentSet = ref(1);
const currentReps = ref(0);
const isResting = ref(false);
const restTimeLeft = ref(0);
const showingResults = ref(false);

// Timed exercise state (e.g., plank)
const timedExerciseSeconds = ref(0);
const targetTimedSeconds = ref(30); // Default target time for plank
let timedExerciseInterval: ReturnType<typeof setInterval> | null = null;

// Training stats
const totalReps = ref(0);
const accuracy = ref(0);
const startTime = ref<Date | null>(null);
const endTime = ref<Date | null>(null);

// AI detection state
const isDetectingMovement = ref(false);
const formQuality = ref(0); // 0-100
const lastReps = ref(0);

// Per-exercise statistics for persistence
interface ExerciseStats {
  reps: number;
  duration: number;
  formAccuracySum: number;
  formAccuracyCount: number;
  startTime: Date | null;
}
const exerciseStats = ref<Map<number, ExerciseStats>>(new Map());

// Form corrections display
const displayedCorrections = ref<string[]>([]);

// Workout persistence
const { saveWorkout } = useWorkouts();
const saving = ref(false);
const unlockedAchievements = ref<any[]>([]);
const showAchievementDialog = ref(false);

// Animation frame ID for cleanup
let animationFrameId: number | null = null;

const currentExercise = computed(
  () => props.exercises[currentExerciseIndex.value]
);

const isExerciseComplete = computed(() => {
  if (!currentExercise.value) return false;
  return currentSet.value > currentExercise.value.sets;
});

const progress = computed(() => {
  const totalExercises = props.exercises.length;
  const completed = currentExerciseIndex.value;
  return Math.round((completed / totalExercises) * 100);
});

const elapsedTime = computed(() => {
  if (!startTime.value) return "0:00";
  const now = endTime.value || new Date();
  const diff = Math.floor((now.getTime() - startTime.value.getTime()) / 1000);
  const minutes = Math.floor(diff / 60);
  const seconds = diff % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
});

// Check if current exercise is timed (like plank)
const isCurrentExerciseTimed = computed(() => {
  if (!currentExercise.value) return false;
  const exerciseType = getExerciseType(currentExercise.value.name);
  return isTimedExercise(exerciseType);
});

// Get exercise type identifier
const getExerciseType = (exerciseName: string): string => {
  const mapping: Record<string, string> = {
    Приседания: "squat",
    Выпады: "lunge",
    Отжимания: "pushup",
    Планка: "plank",
    Пресс: "situp",
    Скручивания: "crunch",
    "Подъем на бицепс": "bicep_curl",
    "Разведение рук": "lateral_raise",
    "Жим вверх": "overhead_press",
    "Подъем ног": "leg_raise",
    "Подъем коленей": "knee_raise",
    "Сгибание коленей": "knee_press",
  };
  return mapping[exerciseName] || "squat";
};

// Initialize camera
const initCamera = async () => {
  try {
    const mediaStream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: "user", width: 1280, height: 720 },
      audio: false,
    });

    stream.value = mediaStream;

    if (videoRef.value) {
      videoRef.value.srcObject = mediaStream;
      videoRef.value.onloadedmetadata = () => {
        videoRef.value?.play();
        isCameraReady.value = true;
        startTime.value = new Date();

        // Store intrinsic video dimensions (original video size from camera)
        if (videoRef.value) {
          videoIntrinsicWidth.value = videoRef.value.videoWidth;
          videoIntrinsicHeight.value = videoRef.value.videoHeight;
        }

        // Wait for video to be displayed, then initialize canvas
        setTimeout(() => {
          updateCanvasSize();
          // Start pose detection loop after camera is ready
          startPoseDetection();
        }, 100);

        // Update canvas on resize (for mobile orientation changes)
        window.addEventListener("resize", updateCanvasSize);
      };
    }
  } catch (error) {
    console.error("Camera error:", error);
    cameraError.value =
      "Не удалось получить доступ к камере. Проверьте разрешения.";
  }
};

// Start timed exercise timer (for plank, etc.)
const startTimedExerciseTimer = () => {
  if (timedExerciseInterval) return; // Already running

  timedExerciseInterval = setInterval(() => {
    if (isInPosition.value && !isResting.value && !showingResults.value) {
      timedExerciseSeconds.value++;

      // Update form quality for timed exercises
      formQuality.value = Math.min(95, 70 + timedExerciseSeconds.value);

      // Check if target time reached
      if (currentExercise.value && timedExerciseSeconds.value >= currentExercise.value.reps) {
        handleTimedExerciseComplete();
      }
    }
  }, 1000);
};

// Stop timed exercise timer
const stopTimedExerciseTimer = () => {
  if (timedExerciseInterval) {
    clearInterval(timedExerciseInterval);
    timedExerciseInterval = null;
  }
};

// Handle timed exercise complete (e.g., plank reached 30 seconds)
const handleTimedExerciseComplete = () => {
  if (!currentExercise.value) return;

  const exIndex = currentExerciseIndex.value;

  // Initialize stats for this exercise if not exists
  if (!exerciseStats.value.has(exIndex)) {
    exerciseStats.value.set(exIndex, {
      reps: 0,
      duration: 0,
      formAccuracySum: 0,
      formAccuracyCount: 0,
      startTime: new Date(),
    });
  }

  const stats = exerciseStats.value.get(exIndex)!;
  stats.reps = timedExerciseSeconds.value; // For timed exercises, reps = seconds
  stats.formAccuracySum += formQuality.value;
  stats.formAccuracyCount++;

  totalReps.value += timedExerciseSeconds.value;

  // Update average accuracy
  accuracy.value = Math.floor(
    (accuracy.value * (totalReps.value - timedExerciseSeconds.value) + formQuality.value * timedExerciseSeconds.value) /
      totalReps.value
  );

  // Stop timer and move to next
  stopTimedExerciseTimer();
  handleSetComplete();
};

// Start local pose detection loop
const startPoseDetection = () => {
  const detectPose = async () => {
    if (
      !videoRef.value ||
      !mediaPipeReady.value ||
      isResting.value ||
      showingResults.value
    ) {
      animationFrameId = requestAnimationFrame(detectPose);
      return;
    }

    try {
      const exerciseType = currentExercise.value
        ? getExerciseType(currentExercise.value.name)
        : "squat";

      await processFrame(videoRef.value, exerciseType);

      // Update keypoints visualization
      if (keypoints.value) {
        drawSkeleton();
      }

      // Handle timed exercises differently
      if (isCurrentExerciseTimed.value) {
        // Start timer if not already running
        startTimedExerciseTimer();
      } else {
        // Check for rep count changes for regular exercises
        if (detectedReps.value !== lastReps.value) {
          handleRepDetected(detectedReps.value);
          lastReps.value = detectedReps.value;
        }
      }

      // Calculate form quality based on angle (for non-timed exercises)
      if (!isCurrentExerciseTimed.value && currentAngle.value !== null) {
        formQuality.value = Math.min(
          95,
          Math.max(70, Math.floor(currentAngle.value / 2))
        );
      }

      // Handle form corrections
      if (formCorrections.value.length > 0) {
        displayedCorrections.value = [...formCorrections.value];
        // Auto-hide after 3 seconds
        setTimeout(() => {
          displayedCorrections.value = [];
        }, 3000);
      }
    } catch (error) {
      console.error("Pose detection error:", error);
    }

    animationFrameId = requestAnimationFrame(detectPose);
  };

  animationFrameId = requestAnimationFrame(detectPose);
};

// Handle rep detected from local counter
const handleRepDetected = (reps: number) => {
  if (!currentExercise.value) return;

  const exIndex = currentExerciseIndex.value;

  // Initialize stats for this exercise if not exists
  if (!exerciseStats.value.has(exIndex)) {
    exerciseStats.value.set(exIndex, {
      reps: 0,
      duration: 0,
      formAccuracySum: 0,
      formAccuracyCount: 0,
      startTime: new Date(),
    });
  }

  const stats = exerciseStats.value.get(exIndex)!;
  stats.reps++;
  stats.formAccuracySum += formQuality.value;
  stats.formAccuracyCount++;

  currentReps.value = reps;
  totalReps.value++;

  // Update average accuracy
  accuracy.value = Math.floor(
    (accuracy.value * (totalReps.value - 1) + formQuality.value) /
      totalReps.value
  );

  // Animation
  isDetectingMovement.value = true;
  setTimeout(() => {
    isDetectingMovement.value = false;
  }, 500);

  // Check if set is complete
  if (currentReps.value >= currentExercise.value.reps) {
    handleSetComplete();
  }
};

// Update canvas size to match displayed video size
const updateCanvasSize = () => {
  if (!canvasRef.value || !videoRef.value) return;

  const displayedWidth = videoRef.value.clientWidth;
  const displayedHeight = videoRef.value.clientHeight;

  const dpr = window.devicePixelRatio || 1;
  const targetWidth = Math.round(displayedWidth * dpr);
  const targetHeight = Math.round(displayedHeight * dpr);

  if (
    canvasRef.value.width !== targetWidth ||
    canvasRef.value.height !== targetHeight
  ) {
    canvasRef.value.width = targetWidth;
    canvasRef.value.height = targetHeight;
  }

  if (keypoints.value) drawSkeleton();
};

// Scale keypoints from intrinsic video size to displayed size
const scaleKeypoints = (
  points: number[][],
  fromWidth: number,
  fromHeight: number,
  toWidth: number,
  toHeight: number
): [number, number][] => {
  const scale = Math.max(toWidth / fromWidth, toHeight / fromHeight);
  const offsetX = (toWidth - fromWidth * scale) / 2;
  const offsetY = (toHeight - fromHeight * scale) / 2;

  return points.map((point): [number, number] => [
    (point[0] ?? 0) * scale + offsetX,
    (point[1] ?? 0) * scale + offsetY,
  ]);
};

// Draw skeleton on canvas
const drawSkeleton = () => {
  if (!canvasRef.value || !keypoints.value || !videoRef.value) return;

  const canvas = canvasRef.value;
  const ctx = canvas.getContext("2d");
  if (!ctx) return;

  // Get displayed video dimensions
  const displayedWidth = videoRef.value.clientWidth;
  const displayedHeight = videoRef.value.clientHeight;

  const dpr = window.devicePixelRatio || 1;
  const targetWidth = Math.round(displayedWidth * dpr);
  const targetHeight = Math.round(displayedHeight * dpr);

  if (canvas.width !== targetWidth || canvas.height !== targetHeight) {
    canvas.width = targetWidth;
    canvas.height = targetHeight;
  }

  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

  // Clear canvas
  ctx.clearRect(0, 0, displayedWidth, displayedHeight);

  // Scale keypoints from intrinsic video size to displayed size
  const scaledKeypoints = scaleKeypoints(
    keypoints.value,
    videoIntrinsicWidth.value,
    videoIntrinsicHeight.value,
    displayedWidth,
    displayedHeight
  );

  // Mirror coordinates because canvas is mirrored via CSS transform: scaleX(-1)
  // Formula: mirrored_x = canvas_width - original_x
  const mirrorKeypoints = (points: [number, number][]): [number, number][] => {
    return points.map((point): [number, number] => [displayedWidth - point[0], point[1]]);
  };

  const mirroredKeypoints = mirrorKeypoints(scaledKeypoints);
  const mirroredAnglePoint = anglePoint.value
    ? mirrorKeypoints(
        scaleKeypoints(
          anglePoint.value,
          videoIntrinsicWidth.value,
          videoIntrinsicHeight.value,
          displayedWidth,
          displayedHeight
        )
      )
    : null;

  // Define skeleton connections (COCO 17 format)
  const connections: [number, number][] = [
    // Head
    [0, 1],
    [0, 2],
    [1, 3],
    [2, 4],
    // Torso
    [5, 6],
    [5, 11],
    [6, 12],
    [11, 12],
    // Arms
    [5, 7],
    [7, 9],
    [6, 8],
    [8, 10],
    // Legs
    [11, 13],
    [13, 15],
    [12, 14],
    [14, 16],
  ];

  const colors = {
    head: "#3399FF",
    torso: "#FF9933",
    arms: "#99FF33",
    legs: "#FF3399",
  } as const;

  // Draw connections
  connections.forEach((connection, index) => {
    const [i, j] = connection;
    const point1 = mirroredKeypoints[i];
    const point2 = mirroredKeypoints[j];

    if (!point1 || !point2) return;

    if (
      point1[0] >= 0 &&
      point1[0] <= displayedWidth &&
      point1[1] >= 0 &&
      point1[1] <= displayedHeight &&
      point2[0] >= 0 &&
      point2[0] <= displayedWidth &&
      point2[1] >= 0 &&
      point2[1] <= displayedHeight
    ) {
      ctx.strokeStyle =
        index < 4
          ? colors.head
          : index < 8
          ? colors.torso
          : index < 12
          ? colors.arms
          : colors.legs;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(point1[0], point1[1]);
      ctx.lineTo(point2[0], point2[1]);
      ctx.stroke();
    }
  });

  // Draw keypoints
  mirroredKeypoints.forEach((point) => {
    if (!point) return;
    if (
      point[0] >= 0 &&
      point[0] <= displayedWidth &&
      point[1] >= 0 &&
      point[1] <= displayedHeight
    ) {
      ctx.fillStyle = "#CCFF00";
      ctx.beginPath();
      ctx.arc(point[0], point[1], 5, 0, 2 * Math.PI);
      ctx.fill();
    }
  });

  // Draw angle lines if available
  if (mirroredAnglePoint && mirroredAnglePoint.length === 3) {
    const p0 = mirroredAnglePoint[0];
    const p1 = mirroredAnglePoint[1];
    const p2 = mirroredAnglePoint[2];

    if (p0 && p1 && p2) {
      const angleInBounds =
        p0[0] >= 0 && p0[0] <= displayedWidth &&
        p0[1] >= 0 && p0[1] <= displayedHeight &&
        p1[0] >= 0 && p1[0] <= displayedWidth &&
        p1[1] >= 0 && p1[1] <= displayedHeight &&
        p2[0] >= 0 && p2[0] <= displayedWidth &&
        p2[1] >= 0 && p2[1] <= displayedHeight;

      if (angleInBounds) {
        ctx.strokeStyle = "#FFFF00";
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.moveTo(p0[0], p0[1]);
        ctx.lineTo(p1[0], p1[1]);
        ctx.lineTo(p2[0], p2[1]);
        ctx.stroke();
      }
    }
  }
};

const handleSetComplete = () => {
  if (!currentExercise.value) return;

  if (currentSet.value < currentExercise.value.sets) {
    // Transition to rest between sets
    startRest(30); // 30 seconds rest
  } else {
    // Exercise complete, move to next
    moveToNextExercise();
  }
};

const startRest = (seconds: number) => {
  isResting.value = true;
  restTimeLeft.value = seconds;

  // Stop timed exercise timer during rest
  stopTimedExerciseTimer();

  const restInterval = setInterval(() => {
    restTimeLeft.value--;

    if (restTimeLeft.value <= 0) {
      clearInterval(restInterval);
      isResting.value = false;
      currentSet.value++;
      currentReps.value = 0;
      lastReps.value = 0;
      timedExerciseSeconds.value = 0; // Reset timed exercise seconds

      // Reset local counter
      resetMediaPipeCounter();
    }
  }, 1000);
};

const moveToNextExercise = () => {
  // Calculate duration for completed exercise
  const stats = exerciseStats.value.get(currentExerciseIndex.value);
  if (stats && stats.startTime) {
    stats.duration = Math.floor(
      (new Date().getTime() - stats.startTime.getTime()) / 1000
    );
  }

  if (currentExerciseIndex.value < props.exercises.length - 1) {
    // Transition to next exercise
    currentExerciseIndex.value++;
    currentSet.value = 1;
    currentReps.value = 0;
    lastReps.value = 0;

    // Reset local counter
    resetMediaPipeCounter();

    // Rest between exercises
    startRest(60); // 60 seconds rest
  } else {
    // Workout complete
    completeWorkout();
  }
};

const completeWorkout = async () => {
  endTime.value = new Date();
  showingResults.value = true;
  saving.value = true;

  // Stop pose detection
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
    animationFrameId = null;
  }

  // Stop camera
  if (stream.value) {
    stream.value.getTracks().forEach((track) => track.stop());
  }

  // Prepare workout data for persistence
  try {
    const workoutData = {
      plan_day_id: props.planDayId,
      started_at: startTime.value?.toISOString() || new Date().toISOString(),
      completed_at: endTime.value.toISOString(),
      total_duration: Math.floor(
        (endTime.value.getTime() -
          (startTime.value?.getTime() || endTime.value.getTime())) /
          1000
      ),
      total_calories: 0, // Backend will calculate this
      average_form_accuracy: accuracy.value / 100, // Backend expects 0.0-1.0
      exercises: props.exercises.map((ex, idx) => {
        const stats = exerciseStats.value.get(idx) || {
          reps: 0,
          duration: 0,
          formAccuracySum: 0,
          formAccuracyCount: 0,
        };

        return {
          exercise_type: getExerciseType(ex.name),
          reps: stats.reps,
          duration: stats.duration,
          form_accuracy:
            stats.formAccuracyCount > 0
              ? stats.formAccuracySum / stats.formAccuracyCount / 100
              : 0,
          form_corrections: [], // Detailed corrections not yet stored per exercise
          calories_burned: 0, // Backend will calculate this
          order_index: idx,
        };
      }),
    };

    console.log("Saving workout session...", workoutData);
    const response = (await saveWorkout(workoutData)) as any;
    console.log("Workout saved successfully:", response);

    // Check for achievements
    if (response.new_achievements && response.new_achievements.length > 0) {
      unlockedAchievements.value = response.new_achievements;
      showAchievementDialog.value = true;

      // Multi-burst confetti for achievements
      const duration = 3 * 1000;
      const end = Date.now() + duration;

      const frame = () => {
        confetti({
          particleCount: 2,
          angle: 60,
          spread: 55,
          origin: { x: 0 },
          colors: ["#CCFF00", "#3399FF"],
        });
        confetti({
          particleCount: 2,
          angle: 120,
          spread: 55,
          origin: { x: 1 },
          colors: ["#CCFF00", "#FF3399"],
        });

        if (Date.now() < end) {
          requestAnimationFrame(frame);
        }
      };
      frame();
    } else {
      // Standard confetti for completion
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
        colors: ["#CCFF00", "#FFFFFF"],
      });
    }
  } catch (error) {
    console.error("Failed to save workout:", error);
    // We still show results to user, but log error
  } finally {
    saving.value = false;
  }
};

const skipRest = () => {
  if (isResting.value) {
    restTimeLeft.value = 0;
  }
};

const exitTraining = () => {
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }
  stopTimedExerciseTimer();
  if (stream.value) {
    stream.value.getTracks().forEach((track) => track.stop());
  }
  emit("endTraining");
};

onMounted(async () => {
  // Initialize MediaPipe first
  await initializeMediaPipe();
  // Then initialize camera
  await initCamera();
});

onUnmounted(() => {
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }
  stopTimedExerciseTimer();
  if (stream.value) {
    stream.value.getTracks().forEach((track) => track.stop());
  }
  window.removeEventListener("resize", updateCanvasSize);
});
</script>

<template>
  <div class="fixed inset-0 bg-black z-50 flex flex-col">
    <!-- Camera View -->
    <div class="relative flex-1 overflow-hidden">
      <!-- Video Stream -->
      <video
        ref="videoRef"
        class="w-full h-full object-cover mirror"
        autoplay
        playsinline
        muted
      />

      <!-- Canvas Overlay for Skeleton -->
      <canvas
        ref="canvasRef"
        class="absolute top-0 left-0 w-full h-full pointer-events-none mirror"
      />

      <!-- Form Corrections Display -->
      <div
        v-if="displayedCorrections.length > 0"
        class="absolute top-32 left-0 right-0 px-6 z-10 animate-in fade-in slide-in-from-top-4 duration-300"
      >
        <div
          class="bg-orange-500/90 backdrop-blur rounded-xl p-4 shadow-lg border border-white/10"
        >
          <div class="flex items-center gap-2 mb-2 text-white">
            <Icon icon="heroicons:exclamation-triangle" class="text-xl" />
            <p class="font-bold">Улучшите технику:</p>
          </div>
          <ul class="space-y-1">
            <li
              v-for="(correction, idx) in displayedCorrections"
              :key="idx"
              class="text-white text-sm"
            >
              {{ correction }}
            </li>
          </ul>
        </div>
      </div>

      <!-- Loading Status -->
      <div
        v-if="mediaPipeLoading && isCameraReady"
        class="absolute top-20 left-1/2 transform -translate-x-1/2 px-4 py-2 bg-blue-500/90 backdrop-blur rounded-full text-white text-sm font-medium z-10"
      >
        Загрузка AI модели...
      </div>

      <!-- MediaPipe Error -->
      <div
        v-if="mediaPipeError && isCameraReady"
        class="absolute top-20 left-1/2 transform -translate-x-1/2 px-4 py-2 bg-orange-500/90 backdrop-blur rounded-full text-white text-sm font-medium z-10"
      >
        {{ mediaPipeError }}
      </div>

      <!-- Camera Error -->
      <div
        v-if="cameraError"
        class="absolute inset-0 flex items-center justify-center bg-black/80 p-6"
      >
        <div class="text-center">
          <Icon
            icon="heroicons:exclamation-triangle"
            class="text-6xl text-red-500 mx-auto mb-4"
          />
          <p class="text-white mb-4">{{ cameraError }}</p>
          <button
            @click="exitTraining"
            class="px-6 py-3 bg-neon text-black rounded-xl font-bold"
          >
            Вернуться назад
          </button>
        </div>
      </div>

      <!-- Top Controls -->
      <div
        class="absolute top-0 left-0 right-0 p-4 bg-gradient-to-b from-black/80 to-transparent"
      >
        <div class="flex justify-between items-center">
          <button
            @click="exitTraining"
            class="w-10 h-10 rounded-full bg-black/50 backdrop-blur flex items-center justify-center text-white"
          >
            <Icon icon="heroicons:x-mark" class="text-xl" />
          </button>

          <div class="flex items-center gap-4">
            <!-- Timer -->
            <div
              class="px-4 py-2 rounded-full bg-black/50 backdrop-blur text-white font-mono"
            >
              {{ elapsedTime }}
            </div>

            <!-- Set Progress -->
            <div
              v-if="!isResting && currentExercise"
              class="px-4 py-2 rounded-full bg-black/50 backdrop-blur text-white font-bold text-sm"
            >
              Подход {{ currentSet }} из {{ currentExercise.sets }}
            </div>
          </div>
        </div>
      </div>

      <!-- Exercise Info -->
      <div
        v-if="!showingResults && currentExercise"
        class="absolute bottom-0 left-0 right-0 px-6 pt-8 pb-28 bg-gradient-to-t from-black via-black to-transparent"
      >
        <!-- Rest Mode -->
        <div v-if="isResting" class="text-center">
          <h2 class="text-2xl font-bold text-neon mb-3">Отдых</h2>
          <div class="text-7xl font-bold text-white mb-6 leading-none">
            {{ restTimeLeft }}<span class="text-4xl">s</span>
          </div>
          <button
            @click="skipRest"
            class="px-8 py-3 bg-white/10 backdrop-blur text-white rounded-xl font-bold text-base"
          >
            Пропустить отдых
          </button>
        </div>

        <!-- Exercise Mode -->
        <div v-else>
          <div class="text-center">
            <h2 class="text-2xl font-bold text-white mb-4">
              {{ currentExercise.name }}
            </h2>

            <!-- Timed Exercise (Plank) -->
            <template v-if="isCurrentExerciseTimed">
              <!-- Timer Display -->
              <div class="text-7xl font-bold mb-4 leading-none">
                <span :class="isInPosition ? 'text-neon' : 'text-white/50'">{{ timedExerciseSeconds }}</span>
                <span class="text-white/40 text-5xl">/</span>
                <span class="text-white">{{ currentExercise.reps }}</span>
                <span class="text-2xl text-white/60 ml-2">сек</span>
              </div>

              <!-- Position Status -->
              <div class="mb-4">
                <div
                  :class="[
                    'inline-flex items-center gap-2 px-4 py-2 rounded-full font-bold text-sm transition-all',
                    isInPosition
                      ? 'bg-neon/20 text-neon'
                      : 'bg-orange-500/20 text-orange-400'
                  ]"
                >
                  <div
                    :class="[
                      'w-3 h-3 rounded-full',
                      isInPosition ? 'bg-neon animate-pulse' : 'bg-orange-400'
                    ]"
                  />
                  {{ isInPosition ? 'Держите позицию!' : 'Примите позицию планки' }}
                </div>
              </div>

              <!-- Progress bar -->
              <div class="flex items-center justify-center gap-3">
                <div class="w-40 h-2 bg-white/10 rounded-full overflow-hidden">
                  <div
                    class="h-full bg-neon transition-all duration-300"
                    :style="{ width: `${(timedExerciseSeconds / currentExercise.reps) * 100}%` }"
                  />
                </div>
                <span class="text-gray-400 text-sm font-medium">
                  {{ Math.round((timedExerciseSeconds / currentExercise.reps) * 100) }}%
                </span>
              </div>
            </template>

            <!-- Regular Exercise (Reps) -->
            <template v-else>
              <!-- Rep Counter -->
              <div class="text-7xl font-bold mb-4 leading-none">
                <span class="text-neon">{{ currentReps }}</span>
                <span class="text-white/40 text-5xl">/</span>
                <span class="text-white">{{ currentExercise.reps }}</span>
              </div>

              <!-- Form Quality -->
              <div class="flex items-center justify-center gap-3">
                <div class="w-40 h-2 bg-white/10 rounded-full overflow-hidden">
                  <div
                    class="h-full bg-neon transition-all duration-300"
                    :style="{ width: `${formQuality}%` }"
                  />
                </div>
                <span class="text-gray-400 text-sm font-medium"
                  >Форма: {{ formQuality }}%</span
                >
              </div>
            </template>

            <!-- Angle Display -->
            <div v-if="currentAngle" class="mt-3 text-gray-400 text-sm">
              Угол: {{ currentAngle }}°
            </div>
          </div>
        </div>
      </div>

      <!-- Results Screen -->
      <div
        v-if="showingResults"
        class="absolute inset-0 bg-black/95 backdrop-blur flex items-center justify-center p-6"
      >
        <div class="text-center max-w-sm w-full">
          <div
            class="w-20 h-20 rounded-full bg-neon/10 flex items-center justify-center mx-auto mb-6"
          >
            <Icon icon="heroicons:trophy" class="text-5xl text-neon" />
          </div>

          <h1 class="text-4xl font-bold text-white mb-2">Отличная работа!</h1>
          <p class="text-gray-400 mb-8">Тренировка завершена</p>

          <!-- Stats Grid -->
          <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Время</p>
              <p class="text-2xl font-bold text-white">{{ elapsedTime }}</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Повторения</p>
              <p class="text-2xl font-bold text-neon">{{ totalReps }}</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Точность</p>
              <p class="text-2xl font-bold text-white">{{ accuracy }}%</p>
            </div>

            <div class="bg-[#111] rounded-2xl p-4">
              <p class="text-gray-400 text-sm mb-1">Калории</p>
              <p class="text-2xl font-bold text-white">
                ~{{ Math.floor(totalReps * 0.5) }}
              </p>
            </div>
          </div>

          <button
            @click="exitTraining"
            :disabled="saving"
            class="w-full py-4 rounded-xl bg-neon text-black font-bold text-lg hover:brightness-110 active:scale-[0.98] transition-all flex items-center justify-center gap-2"
          >
            <Icon
              v-if="saving"
              icon="heroicons:arrow-path"
              class="animate-spin"
            />
            <span>{{ saving ? "Сохранение..." : "Завершить тренировку" }}</span>
          </button>
        </div>
      </div>
      <!-- Achievements Dialog -->
      <div
        v-if="showAchievementDialog"
        class="fixed inset-0 flex items-center justify-center z-[60] px-6 bg-black/40 backdrop-blur-sm"
        @click.self="showAchievementDialog = false"
      >
        <div
          class="bg-[#111] border border-neon/30 rounded-3xl p-6 max-w-sm w-full text-center shadow-[0_0_50px_rgba(204,255,0,0.2)]"
        >
          <div
            class="w-16 h-16 rounded-full bg-neon/20 flex items-center justify-center mx-auto mb-4"
          >
            <Icon icon="heroicons:trophy" class="text-3xl text-neon" />
          </div>
          <h3 class="text-2xl font-bold text-white mb-1">Новое достижение!</h3>
          <p class="text-gray-400 text-sm mb-6">Вы открыли новые награды</p>

          <div class="space-y-4 mb-8">
            <div
              v-for="ach in unlockedAchievements"
              :key="ach.type"
              class="flex items-center gap-4 bg-white/5 p-3 rounded-2xl"
            >
              <div
                class="w-10 h-10 rounded-full bg-neon/10 flex items-center justify-center text-neon"
              >
                <Icon :icon="`heroicons:${ach.icon}`" class="text-xl" />
              </div>
              <div class="text-left">
                <p class="font-bold text-white text-sm">{{ ach.name }}</p>
                <p class="text-xs text-gray-400">{{ ach.description }}</p>
              </div>
            </div>
          </div>

          <button
            @click="showAchievementDialog = false"
            class="w-full py-3 rounded-xl bg-neon text-black font-bold"
          >
            Круто!
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.text-neon {
  color: var(--color-neon);
}

.bg-neon {
  background-color: var(--color-neon);
}

.bg-neon\/10 {
  background-color: rgba(204, 255, 0, 0.1);
}

.bg-neon\/50 {
  background-color: rgba(204, 255, 0, 0.5);
}

.mirror {
  transform: scaleX(-1);
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes ping {
  75%,
  100% {
    transform: translate(-50%, -50%) scale(2);
    opacity: 0;
  }
}

.animate-ping {
  animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;
}
</style>
