# Building `FinalVideo.mp4`

End-to-end recipe to produce `video/FinalVideo.mp4` from
[`final_video.py`](final_video.py).

## 0. One-time setup

```bash
# From the repo root:
python3 -m venv .venv          # create an isolated Python env
source .venv/bin/activate      # activate it
pip install manim==0.19.1      # install Manim Community
```

You also need `ffmpeg` (used by Manim and by [`build_video.sh`](build_video.sh)
to splice scenes and mix the soundtrack):

```bash
brew install ffmpeg            # macOS
```

`bc` (used by the audio-fade math in the build script) ships with macOS
by default.

## 1. Render every scene

`final_video.py` defines one Manim `Scene` per section. Render them all at
1080p60:

```bash
cd video
source ../.venv/bin/activate
manim -qh final_video.py \
      TitleCard Motivation MSPApproach OurApproach \
      PowExample Novelty MVPDemo Benchmarks Closing
```

Flags:

* `-q h` — high quality preset (1920×1080, 60 fps).  Use `-q l` for a fast
  480p15 smoke render while iterating.
* Each scene class becomes one `.mp4` under
  `media/videos/final_video/1080p60/`.

You can re-render a single scene at a time too — the `build_video.sh` step
below just concatenates whichever files are present in that directory.

## 2. Stitch the scenes + mix the soundtrack

```bash
bash build_video.sh -qh        # 1080p60   (default)
# bash build_video.sh -ql      # 480p15    (low-quality preview)
```

Internally the script does three things:

1. **Build a concat list.** Writes one `file '<Scene>.mp4'` line per scene
   into `media/videos/final_video/1080p60/_concat.txt`, in the order
   declared by `SCENES=(...)` at the top of the script.

2. **Splice losslessly.**
   ```bash
   ffmpeg -f concat -safe 0 -i _concat.txt -c copy FinalVideo_silent.mp4
   ```
   `-c copy` re-muxes the existing H.264 streams without re-encoding, so
   this step is fast and quality-preserving. The result has no audio
   track.

3. **Mix the BGM with normalisation + fades.**
   ```bash
   ffmpeg -i FinalVideo_silent.mp4 -i assets/bgm.mp3 \
     -filter_complex "[1:a]loudnorm=I=-18:TP=-2:LRA=11,
                       afade=t=in:st=0:d=2,
                       afade=t=out:st=$((DUR-2)):d=2[a]" \
     -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest \
     FinalVideo.mp4
   ```
   * `loudnorm=I=-18:TP=-2:LRA=11` — EBU R128 perceived-loudness target
     of −18 LUFS, −2 dB true-peak ceiling, 11 LU loudness range.  The raw
     `bgm.mp3` is mastered very quietly; without this it would be inaudible
     under the narration.
   * `afade=t=in:st=0:d=2` — 2-second fade-in at the start of the audio.
   * `afade=t=out:st=$((DUR-2)):d=2` — 2-second fade-out, ending exactly
     when the video ends (`DUR` is read with `ffprobe`).
   * `-c:v copy` — keep the video stream untouched.
   * `-c:a aac -b:a 192k` — encode the mixed audio as 192 kbps AAC.
   * `-shortest` — stop when the shorter of (video, audio) ends, so a
     longer BGM does not extend past the video.

The script prints the total duration and the output path on success:

```
Done! Final video saved to video/FinalVideo.mp4
Duration: 200.000000 seconds
```

## 3. Replacing the background music

Drop a new `bgm.mp3` (or any ffmpeg-readable audio file) at
`video/assets/bgm.mp3` and re-run step 2. Nothing else changes — the
build script does **not** re-render scenes if their `.mp4` files are
already up to date, so swapping music is essentially instantaneous.

## 4. Iterating on a single scene

While editing, render only the changed scene at low quality and inspect
individual frames:

```bash
cd video
source ../.venv/bin/activate
manim -ql final_video.py PowExample        # 480p15 smoke render
ffmpeg -y -ss 30 -i media/videos/final_video/480p15/PowExample.mp4 \
       -frames:v 1 /tmp/check.png           # extract a frame at t=30s
```

When happy, re-render at `-qh` and `bash build_video.sh -qh`.

## Scene order

Defined once in `build_video.sh` (`SCENES=(...)`):

1. `TitleCard`
2. `Motivation`
3. `MSPApproach`
4. `OurApproach`
5. `PowExample`
6. `Novelty`
7. `MVPDemo`
8. `Benchmarks`
9. `Closing`
