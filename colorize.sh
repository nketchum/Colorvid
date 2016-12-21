#! /bin/sh

rootdir=$(pwd);

frames_mono_dir="$rootdir/frames/mono";
frames_color_dir="$rootdir/frames/color";
frames_mono="$frames_mono_dir/*.png";
frames_color="$frames_color_dir/*.png";

input="$rootdir/input/76409047.mp4";
output="$rootdir/output/out.mp4";

fps=24;

# Make monochrome frames from source vid.
/usr/local/bin/ffmpeg -i "$input" -r $fps "$frames_mono_dir/%04d.png";

# Loop thru monos, colorize, and save.
for frame in $frames_mono; do
  filename=$(basename "$frame");
  th colorize.lua "$frames_mono_dir/$filename" "$frames_color_dir/$filename";
done;

# Assemble color into output vid.
ffmpeg -framerate $fps -pattern_type glob -i "$frames_color" -c:v libx264 "$output";