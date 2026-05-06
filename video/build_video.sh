#!/bin/bash
set -e

# Move to the script's directory (video/)
cd "$(dirname "$0")"

# Default to 1080p60 (high quality). Use -ql for 480p15 (low quality preview).
QUALITY=${1:--qh}
if [ "$QUALITY" = "-ql" ]; then
    RESOLUTION_DIR="480p15"
elif [ "$QUALITY" = "-qh" ]; then
    RESOLUTION_DIR="1080p60"
else
    echo "Unknown quality: $QUALITY. Use -ql or -qh to specify the source directory."
    exit 1
fi

SCENES=(
    TitleCard
    Motivation
    MSPApproach
    OurApproach
    PowExample
    Novelty
    MVPDemo
    Benchmarks
    Closing
)

echo "=== Assembling scenes from $RESOLUTION_DIR ==="
VIDEOS_DIR="media/videos/final_video/$RESOLUTION_DIR"
CONCAT_LIST="$VIDEOS_DIR/_concat.txt"

# Build the concat file list
> "$CONCAT_LIST"
for SCENE in "${SCENES[@]}"; do
    echo "file '${SCENE}.mp4'" >> "$CONCAT_LIST"
done

SILENT_OUT="$VIDEOS_DIR/FinalVideo_silent.mp4"
ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$SILENT_OUT"

echo "=== Mixing audio ==="
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$SILENT_OUT")
FADE_OUT_START=$(echo "$DUR - 2.0" | bc)

FINAL_OUT="FinalVideo.mp4"

# Combine silent video with music, using 2-second fade-in and fade-out.
# loudnorm normalises the bgm to a consistent perceived loudness so the
# final mix is actually audible (the raw mp3 is mastered very quietly).
ffmpeg -y -i "$SILENT_OUT" -i assets/bgm.mp3 \
  -filter_complex "[1:a]loudnorm=I=-18:TP=-2:LRA=11,afade=t=in:st=0:d=2,afade=t=out:st=${FADE_OUT_START}:d=2[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest "$FINAL_OUT"

echo "=========================================="
echo "Done! Final video saved to video/$FINAL_OUT"
echo "Duration: $DUR seconds"
echo "=========================================="
