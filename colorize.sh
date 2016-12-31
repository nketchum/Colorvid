#! /bin/sh

# Root
rootdir=$(pwd);

# Dirs
frames_mono_dir="$rootdir/frames/mono";
frames_trans_dir="$rootdir/frames/trans";
frames_color_dir="$rootdir/frames/color";

# Frames
frames_mono="$frames_mono_dir/*.png";
frames_color="$frames_color_dir/*.png";

# Input-output
video_filename="hOnc45AZVHo_hq.mp4";
input="$rootdir/input/$video_filename";
output_dir="$rootdir/output";
output="$output_dir/$video_filename";

# Framerate (affects performance)
fps=24;

# Create proc directories.
rm -rf "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" "$output_dir" || true;
mkdir -p "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" "$output_dir";

# Make monochrome frames from source vid.
/usr/local/bin/ffmpeg -i "$input" -r $fps "$frames_mono_dir/%04d.png";

# Loop thru monos, colorize, and save.
for frame in $frames_mono; do
  filename=$(basename "$frame");
  # Transform to smaller frames. (requires imagemagick)
  convert "$frames_mono_dir/$filename" -resize 480x480 "$frames_trans_dir/$filename";
  th colorize.lua "$frames_trans_dir/$filename" "$frames_color_dir/$filename";
done;

# Assemble color into output vid.
ffmpeg -framerate $fps -pattern_type glob -i "$frames_color" -c:v libx264 "$output";