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
video_id=$1;
video_filename="$video_id.mp4";
input_dir="$rootdir/input";
input="$input_dir/$video_filename";
output_dir="$rootdir/output";
output="$output_dir/$video_filename";

# Framerate (affects performance)
fps=24;

# Max length (14,400 frames at 24 fps is 10 min)
frames_maxnum=14400;

# Create proc directories.
rm -rf "$input_dir" "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" || true;
mkdir -p "$input_dir" "$frames_mono_dir" "$frames_trans_dir" "$frames_color_dir" "$output_dir";

# Download video. (requires youtube-dl)
youtube-dl "https://www.youtube.com/watch?v=$video_id" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]' -o "$input";

# Make monochrome frames from source vid.
ffmpeg -i "$input" -r $fps "$frames_mono_dir/%05d.png";

# Transform to smaller frames for colorizing (requires imagemagick/convert).
count=0;
for frame in $frames_mono; do
  if [ $count -lt $frames_maxnum ]; then
    filename=$(basename "$frame");
    convert "$frames_mono_dir/$filename" -resize 480x480 "$frames_trans_dir/$filename";
    count=$((count+1));
  else
    break;
  fi;
done;

# Parallel process the colorization step.
args='';
filenames_input=$(find "$frames_trans_dir" -type f -name "*.png");
for arg1 in $filenames_input; do
  arg2=$(echo "$arg1" | sed 's/trans/color/');
  args=$(printf "%s %s\n%s" "$arg1" "$arg2" "$args");
done;
printf "%s\n" "$args" | parallel -j+0 --eta --colsep ' ' th colorize.lua "{1}" "{2}";

# Assemble color into output vid.
ffmpeg -framerate $fps -pattern_type glob -i "$frames_color" -i "$input" -map 0:v -map 1:a -c:v libx264 "$output";

# Remove frames proc directory.
rm -rf "$input_dir" "$rootdir/frames" || true;