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
video_id="lkqz3lpUBp0";
video_filename="$video_id.mp4";
input_dir="$rootdir/input";
input="$input_dir/$video_filename";
output_dir="$rootdir/output";
output="$output_dir/$video_filename";

# Framerate (affects performance)
fps=24;
frames_maxnum=1000;

# Create proc directories.
rm -rf "$input_dir" "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" || true;
mkdir -p "$input_dir" "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" "$output_dir";

# Download video. (requires youtube-dl)
youtube-dl "https://www.youtube.com/watch?v=$video_id" -f 'bestvideo/best' -o "$input";

# Make monochrome frames from source vid.
/usr/local/bin/ffmpeg -i "$input" -r $fps "$frames_mono_dir/%04d.png";

# Loop thru monos, colorize, and save.
count=0;
for frame in $frames_mono; do
  if [ $count -lt $frames_maxnum ]; then
    filename=$(basename "$frame");
    # Transform to smaller frames. (requires imagemagick)
    convert "$frames_mono_dir/$filename" -resize 480x480 "$frames_trans_dir/$filename";
    th colorize.lua "$frames_trans_dir/$filename" "$frames_color_dir/$filename";
    count=$((count+1));
  else
    break;
  fi;
done;

# Assemble color into output vid.
ffmpeg -framerate $fps -pattern_type glob -i "$frames_color" -c:v libx264 "$output";

# Remove frames proc directory.
rm -rf "$input_dir" "$rootdir/frames" || true;