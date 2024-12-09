# video_filter.vpy
import vapoursynth as vs
import sys

core = vs.get_core()

input_video = sys.argv[1]

# Load the video
video = core.ffms2.Source(source=input_video)

# Denoise, using 'estimate' mode
denoised = core.denoise.Estimate(video, radius=3)

# Brighten the video
brightened = core.std.Levels(denoised, min_in=0, max_in=255, min_out=30, max_out=235, gamma=1)

# Sharpen the video
sharpened = core.warpsharp.WarpSharp(brightened)

# Deblock the video
deblocked = core.deblock.Deblock(sharpened)

# Upscale the video using VapourSynth's built-in core.resize
resized = core.resize.Bicubic(deblocked, width=deblocked.width*2, height=deblocked.height*2, filter_param_a=0, filter_param_b=0.75)

# Set the output video
core.set_output(resized)
