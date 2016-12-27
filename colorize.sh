#! /bin/sh

# Root
rootdir=$(pwd);

# Dirs
frames_mono_dir="$rootdir/frames/mono";
frames_color_dir="$rootdir/frames/color";

# Frames
frames_mono="$frames_mono_dir/*.png";
frames_color="$frames_color_dir/*.png";

# Input-output
input="$rootdir/input/n5UnEB23YCI.mp4";
output_dir="$rootdir/output";
output="$output_dir/out.mp4";

# Framerate (affects performance)
fps=24;

# Create proc directories.
rm -rf "$frames_mono_dir" "$frames_color_dir" "$output_dir" || true;
mkdir -p "$frames_mono_dir" "$frames_color_dir" "$output_dir";
# chmod -R 777 "$frames_mono_dir" "$frames_color_dir" "$output_dir";

# Grab remote video
#youtube-dl https://www.youtube.com/watch?v=n5UnEB23YCI -f 'bestvideo[height<=480]+bestaudio/best[height<=480]'

# Make monochrome frames from source vid.
/usr/local/bin/ffmpeg -i "$input" -r $fps "$frames_mono_dir/%04d.png";

# Loop thru monos, colorize, and save.
for frame in $frames_mono; do
  filename=$(basename "$frame");
  th colorize.lua "$frames_mono_dir/$filename" "$frames_color_dir/$filename";
done;

# Assemble color into output vid.
ffmpeg -framerate $fps -pattern_type glob -i "$frames_color" -c:v libx264 "$output";