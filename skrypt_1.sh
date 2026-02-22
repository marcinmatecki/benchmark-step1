#!/bin/bash
set -e

DATASET_PATH="$1"
BASE_OUTPUT_DIR="$2"

if [[ -z "$DATASET_PATH" || -z "$BASE_OUTPUT_DIR" ]]; then
  echo "Usage: $0 <dataset_path> <base_output_dir>"
  exit 1
fi

DATASET_PATH=$(realpath "$DATASET_PATH")
BASE_OUTPUT_DIR=$(realpath "$BASE_OUTPUT_DIR")

DATASET_NAME=$(basename "$DATASET_PATH")

OUTPUT_DIR="$BASE_OUTPUT_DIR/$DATASET_NAME-dataset"
mkdir -p "$OUTPUT_DIR"

echo "==========================================="
echo "Running ALL conversions for: $DATASET_NAME"
echo "Output base directory: $OUTPUT_DIR"
echo "==========================================="

CONVERSION_SCRIPT="./mandeye-convert.sh"
ROS1_PC_SCRIPT="./livox_bag.sh"

echo "HDMapping -> ROS1"
"$CONVERSION_SCRIPT" \
  "$DATASET_PATH" \
  "$OUTPUT_DIR" \
  "hdmapping-to-ros1"

echo "ROS1 -> aggregated pointcloud (-pc)"
"$ROS1_PC_SCRIPT" \
  "$OUTPUT_DIR/$DATASET_NAME" \
  "$OUTPUT_DIR"

ORIGINAL_FILE="$OUTPUT_DIR/$DATASET_NAME"
NEW_FILE="${ORIGINAL_FILE%.bag}"

mv "$ORIGINAL_FILE"-pc.bag "$NEW_FILE"-pc
DATASET_NAME="$(basename "$NEW_FILE")"

echo "HDMapping -> ROS2"
"$CONVERSION_SCRIPT" \
  "$DATASET_PATH" \
  "$OUTPUT_DIR" \
  "hdmapping-to-ros2"

echo "ROS1 -> ROS2"
"$CONVERSION_SCRIPT" \
  "$DATASET_PATH" \
  "$OUTPUT_DIR" \
  "ros1-to-ros2"

echo "==========================================="
echo "ALL conversions finished successfully!"
echo "==========================================="