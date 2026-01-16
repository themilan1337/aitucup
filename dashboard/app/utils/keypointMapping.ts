/**
 * Keypoint mapping from MediaPipe Pose (33 points) to COCO format (17 points)
 *
 * MediaPipe Pose landmarks:
 * 0: nose, 1: left_eye_inner, 2: left_eye, 3: left_eye_outer, 4: right_eye_inner,
 * 5: right_eye, 6: right_eye_outer, 7: left_ear, 8: right_ear, 9: mouth_left,
 * 10: mouth_right, 11: left_shoulder, 12: right_shoulder, 13: left_elbow,
 * 14: right_elbow, 15: left_wrist, 16: right_wrist, 17: left_pinky, 18: right_pinky,
 * 19: left_index, 20: right_index, 21: left_thumb, 22: right_thumb, 23: left_hip,
 * 24: right_hip, 25: left_knee, 26: right_knee, 27: left_ankle, 28: right_ankle,
 * 29: left_heel, 30: right_heel, 31: left_foot_index, 32: right_foot_index
 *
 * COCO 17 format:
 * 0: nose, 1: left_eye, 2: right_eye, 3: left_ear, 4: right_ear,
 * 5: left_shoulder, 6: right_shoulder, 7: left_elbow, 8: right_elbow,
 * 9: left_wrist, 10: right_wrist, 11: left_hip, 12: right_hip,
 * 13: left_knee, 14: right_knee, 15: left_ankle, 16: right_ankle
 */

import type { MediaPipeLandmark, PoseKeypoints } from '~/types/pose';

// Mapping from COCO index to MediaPipe index
export const MEDIAPIPE_TO_COCO_MAPPING: Record<number, number> = {
  0: 0,   // nose -> nose
  1: 2,   // left_eye -> left_eye
  2: 5,   // right_eye -> right_eye
  3: 7,   // left_ear -> left_ear
  4: 8,   // right_ear -> right_ear
  5: 11,  // left_shoulder -> left_shoulder
  6: 12,  // right_shoulder -> right_shoulder
  7: 13,  // left_elbow -> left_elbow
  8: 14,  // right_elbow -> right_elbow
  9: 15,  // left_wrist -> left_wrist
  10: 16, // right_wrist -> right_wrist
  11: 23, // left_hip -> left_hip
  12: 24, // right_hip -> right_hip
  13: 25, // left_knee -> left_knee
  14: 26, // right_knee -> right_knee
  15: 27, // left_ankle -> left_ankle
  16: 28, // right_ankle -> right_ankle
};

// Number of COCO keypoints
export const COCO_KEYPOINT_COUNT = 17;

// Visibility threshold for valid keypoints
export const VISIBILITY_THRESHOLD = 0.5;

/**
 * Convert MediaPipe Pose landmarks to COCO 17 format keypoints
 * Scales coordinates from normalized (0-1) to pixel coordinates
 * Mirrors X coordinate since the video is displayed mirrored (selfie mode)
 */
export function mediaPipeToCoco(
  landmarks: MediaPipeLandmark[],
  imageWidth: number,
  imageHeight: number
): PoseKeypoints {
  const cocoKeypoints: PoseKeypoints = [];

  for (let cocoIdx = 0; cocoIdx < COCO_KEYPOINT_COUNT; cocoIdx++) {
    const mpIdx = MEDIAPIPE_TO_COCO_MAPPING[cocoIdx];

    if (mpIdx === undefined) {
      cocoKeypoints.push([0, 0]);
      continue;
    }

    const landmark = landmarks[mpIdx];

    if (landmark && landmark.visibility >= VISIBILITY_THRESHOLD) {
      // MediaPipe returns normalized coordinates (0-1), scale to pixel coordinates
      // Mirror X coordinate for selfie mode display
      cocoKeypoints.push([
        (1 - landmark.x) * imageWidth,
        landmark.y * imageHeight
      ]);
    } else {
      // Invalid or low-visibility keypoint
      cocoKeypoints.push([0, 0]);
    }
  }

  return cocoKeypoints;
}

/**
 * Get angle point coordinates from keypoints based on exercise config
 */
export function getAnglePointCoords(
  keypoints: PoseKeypoints,
  anglePointIndices: number[]
): number[][] {
  return anglePointIndices.map(idx => keypoints[idx] || [0, 0]);
}

/**
 * Check if keypoints are valid (not at origin)
 */
export function isValidKeypoint(point: number[]): boolean {
  return point[0] !== 0 || point[1] !== 0;
}

/**
 * Check if all required keypoints for an exercise are visible
 */
export function areKeypointsVisible(
  keypoints: PoseKeypoints,
  requiredIndices: number[]
): boolean {
  return requiredIndices.every(idx => {
    const point = keypoints[idx];
    return point && isValidKeypoint(point);
  });
}
