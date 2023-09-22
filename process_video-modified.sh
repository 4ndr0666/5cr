#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${GREEN}"
cat << "EOF"

#  ____   ____.__    .___.__  .__                          .__
#  \   \ /   /|__| __| _/|  | |__| ____   ____        _____|  |__
#   \   Y   / |  |/ __ | |  | |  |/    \_/ __ \      /  ___/  |  \
#    \     /  |  / /_/ | |  |_|  |   |  \  ___/      \___ \|   Y  \
#     \___/   |__\____ | |____/__|___|  /\___  > /\ /____  >___|  /
#                     \/              \/     \/  \/      \/     \/

EOF
echo -e "${RESET}"

# Error handling function
error_exit() {
    echo -e "${RED}ERROR: $1${RESET}" >&2
    exit 1
}
trap 'echo "An error occurred. Exiting."; exit 1' ERR

# Check for necessary dependencies
dependencies=("ffmpeg" "mpv" "vspipe")
for dep in "${dependencies[@]}"; do
    if ! command -v $dep &> /dev/null; then
        echo "Error: $dep is not installed" >&2
        exit 1
    fi
done

# Function to allow user input with autocompletion for video files
while true; do
    echo -n "Enter input video: "
    read -e input_video
    if [[ -f "$input_video" ]]; then
        INPUT_VIDEO="$input_video"
        break
    else
        echo "Error: Input video '$input_video' does not exist"
    fi
done

echo "Enter output video name (without extension, will default to 'output' if left blank):"
read OUTPUT_NAME
OUTPUT_NAME=${OUTPUT_NAME:-output}

# Check video extension and set default if not provided
OUTPUT_VIDEO_EXT=${OUTPUT_NAME##*.}
if [[ "$OUTPUT_NAME" == "$OUTPUT_VIDEO_EXT" ]]; then
    OUTPUT_VIDEO_EXT="mp4"  # Default extension
fi
OUTPUT_VIDEO="$OUTPUT_NAME.$OUTPUT_VIDEO_EXT"

# Check if the output file is writable or if it doesn't exist
if [[ -e "$OUTPUT_VIDEO" && ! -w "$OUTPUT_VIDEO" ]]; then
    echo "Error: Output video '$OUTPUT_VIDEO' is not writable" >&2
    exit 1
fi

# PS3 and transformations menu start here...
PS3='Please select a transformation: '
options=("Frame Rate Conversion" "Inverse Telecine (IVTC)" "Deflicker" "Dedot" "Dehalo" "Grain Generation" "RemoveGrain" "Debanding" "Sharpening & Edge Enhancement" "Color Correction" "Super Resolution" "Deshake" "Edge Detection" "Zooming" "Stabilization" "Slo-mo" "Basic video converter" "Enhanced SVP Transformation")

select opt in "${options[@]}"
do
    case $opt in
        "Frame Rate Conversion")
            echo "Frame Rate Conversion logic here"
            break
            ;;
        "Denoising (Basic)")
            echo "Denoising logic here"
            break
            ;;
        "Inverse Telecine (IVTC)")
            echo "Inverse Telecine (IVTC) logic here"
            break
            ;;
        "Deflicker")
            echo "Deflicker logic here"
            break
            ;;
        "Dedot")
            echo "Dedot logic here"
            break
            ;;
        "Dehalo")
            echo "Dehalo logic here"
            break
            ;;
        "Grain Generation")
            echo "Grain Generation logic here"
            break
            ;;
        "RemoveGrain")
            echo "RemoveGrain logic here"
            break
            ;;
        "Debanding")
            echo "Debanding logic here"
            break
            ;;
        "Sharpening & Edge Enhancement")
            echo "Sharpening & Edge Enhancement logic here"
            break
            ;;
        "Color Correction")
            echo "Color Correction logic here"
            break
            ;;
        "Super Resolution")
            echo "Super Resolution logic here"
            break
            ;;
        "Deshake")
            echo "Deshake logic here"
            break
            ;;
        "Edge Detection")
            echo "Edge Detection logic here"
            break
            ;;
        "Zooming")
            echo "Zooming logic here"
            break
            ;;
        "Stabilization")
            echo "Stabilization logic here"
            break
            ;;
        "Slo-mo")
            echo "Slo-mo logic here"
            break
            ;;
        "Basic video converter")
            echo "Basic video converter logic here"
            break
            ;;
        "Enhanced SVP Transformation")
            echo "Enhanced SVP Transformation logic here"
            break
            ;;
    esac
done  
select opt in "${options[@]}"
do
# ...

case $opt in
    "Frame Rate Conversion")
        echo "Enter desired frame rate (e.g., 24, 30, 60):"
        read DESIRED_FPS
        transformation="core.resize.Bilinear(clip, fpsnum=$DESIRED_FPS)"
        ;;
    "Denoising (Basic)")
        echo "You chose the Basic Denoising option."
        # Prompt the user for the desired denoising strength (default is medium)
        echo "Select denoising strength (light, medium, strong):"
        read DENOISE_STRENGTH
        case "$DENOISE_STRENGTH" in
            light)
                DENOSIE_VALUES="4:4:6:6"
                ;;
            medium)
                DENOSIE_VALUES="6:6:8:8"
                ;;
            strong)
                DENOSIE_VALUES="8:8:10:10"
                ;;
            *)
                echo "Invalid choice. Defaulting to medium."
                DENOSIE_VALUES="6:6:8:8"
                ;;
        esac
        # Apply denoising using FFmpeg
        ffmpeg -i "$INPUT_VIDEO" -vf "hqdn3d=${DENOSIE_VALUES}" "${OUTPUT_VIDEO%.*}_denoised.${OUTPUT_VIDEO##*.}"
        echo "Video denoised with ${DENOISE_STRENGTH} strength and saved."
        ;;
    # ... [Other transformations here] ...
    *)
        echo "Invalid option $REPLY"
        ;;
esac

# ...

        "Inverse Telecine (IVTC)")
            transformation="core.vinverse.Vinverse(clip)"
            if $use_ffmpeg_fallback; then
                transformation="ffmpeg -i \"$INPUT_VIDEO\" -vf \"pullup, decimate\" \"$OUTPUT_VIDEO\""
            fi
            ;;

        "Deflicker")
            transformation="haf.Deblock(clip)"
            if $use_ffmpeg_fallback; then
                transformation="ffmpeg -i \"$INPUT_VIDEO\" -vf \"deflicker\" \"$OUTPUT_VIDEO\""
            fi
            ;;

        "Dedot")
            if $use_ffmpeg_fallback; then
                transformation="ffmpeg -i \"$INPUT_VIDEO\" -vf \"hqdn3d=spatial_luma=1\" \"$OUTPUT_VIDEO\""
            else
                echo "This transformation is best handled by FFmpeg. Please ensure FFmpeg is installed and accessible."
                exit 1
            fi
            ;;

        "Dehalo")
            transformation="core.dehalo_alpha.DeHalo_alpha(clip)"
            ;;

        "Grain Generation")
            transformation="core.grain.Add(clip)"
            if $use_ffmpeg_fallback; then
                transformation="ffmpeg -i \"$INPUT_VIDEO\" -vf \"geq=random(1)*256:128:128\" \"$OUTPUT_VIDEO\""
            fi
            ;;

        "RemoveGrain")
            transformation="core.rgvs.RemoveGrain(clip, mode=1)"
            ;;

        "Debanding")
            echo "You chose the Debanding option."

            # Set the parameters for debanding
            DEBAND_PARAMS="16:8:64:64"

            # Apply the deband filter using FFmpeg
            output_file="${INPUT_VIDEO%.*}_deband.mkv"  # Adjusting the output format as needed
            ffmpeg -i "$INPUT_VIDEO" -vf "deband=${DEBAND_PARAMS}" "$output_file"

            echo "Video debanded and saved as $output_file."
            ;;

        "Sharpening & Edge Enhancement")
            echo "You chose the Sharpening & Edge Enhancement option."

            # Prompt the user for the desired sharpening level
            echo "Enter the sharpening level (default is 1.5):"
            read SHARPEN_LEVEL
            : ${SHARPEN_LEVEL:=1.5}

            # Apply the unsharp filter using FFmpeg
            output_file="${INPUT_VIDEO%.*}_sharpen.mkv"  # Adjusting the output format as needed
            ffmpeg -i "$INPUT_VIDEO" -vf "unsharp=luma_msize_x=3:luma_msize_y=3:luma_amount=${SHARPEN_LEVEL}" "$output_file"

            echo "Video sharpened with a level of ${SHARPEN_LEVEL} and saved as $output_file."
            ;;

        "Color Correction")
            echo "You chose the Color Correction option."

            # Prompt the user for the desired adjustments
            echo "Enter brightness adjustment (default is 1.0, can be > or < 1):"
            read BRIGHTNESS
            : ${BRIGHTNESS:=1.0}

            echo "Enter contrast adjustment (default is 1.0, can be > or < 1):"
            read CONTRAST
            : ${CONTRAST:=1.0}

            echo "Enter saturation adjustment (default is 1.0, can be > or < 1):"
            read SATURATION
            : ${SATURATION:=1.0}

            # Apply the eq filter using FFmpeg
            output_file="${INPUT_VIDEO%.*}_color_corrected.mkv"  # Adjusting the output format as needed
            ffmpeg -i "$INPUT_VIDEO" -vf "eq=brightness=${BRIGHTNESS}:contrast=${CONTRAST}:saturation=${SATURATION}" "$output_file"

            echo "Video color-corrected and saved as $output_file."
            ;;

        "Super Resolution")
            echo "You chose the Super Resolution option."

            # Prompt user for the desired upscale factor (2x, 3x, etc.)
            echo "Enter upscale factor (e.g., 2 for 2x, 3 for 3x, etc.):"
            read UPSCALE_FACTOR
            : ${UPSCALE_FACTOR:=2}

            # Calculate new resolution based on the upscale factor
            orig_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$INPUT_VIDEO")
            orig_height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$INPUT_VIDEO")
            new_width=$((orig_width * UPSCALE_FACTOR))
            new_height=$((orig_height * UPSCALE_FACTOR))

            # Upscale video using bicubic method (an alternative to bilinear and lanczos) and add sharpening
            output_file="${INPUT_VIDEO%.*}_upscaled.mkv"
            ffmpeg -i "$INPUT_VIDEO" -vf "scale=${new_width}:${new_height}:flags=bicubic,unsharp=5:5:1.5:5:5:1.5" "$output_file"

            echo "Video upscaled with Super Resolution and saved as $output_file."
            ;;

        "Deshake")
            echo "You chose the Deshake option."

            # Determine the output file name
            output_file="${INPUT_VIDEO%.*}_deshaked.mkv"

            # Apply the deshake filter using FFmpeg
            ffmpeg -i "$INPUT_VIDEO" -vf "deshake" "$output_file"

            echo "Video stabilized and saved as $output_file."
            ;;

        "Edge Detection")
            echo "You chose the Edge Detection option."

            # Determine the output file name
            output_file="${INPUT_VIDEO%.*}_edges.mkv"

            # Apply the edgedetect filter using FFmpeg
            ffmpeg -i "$INPUT_VIDEO" -vf "edgedetect=mode=colormix:high=0" "$output_file"

            echo "Edges detected and saved as $output_file."
            ;;

        "Zooming")
            echo "You chose the Zooming option."

            # Ask the user for the coordinates and size of the area to zoom into
            echo "Enter the x-coordinate of the top-left corner of the zoom area:"
            read ZOOM_X
            echo "Enter the y-coordinate of the top-left corner of the zoom area:"
            read ZOOM_Y
            echo "Enter the width of the zoom area:"
            read ZOOM_WIDTH
            echo "Enter the height of the zoom area:"
            read ZOOM_HEIGHT

            # Determine the output file name
            output_file="${INPUT_VIDEO%.*}_zoomed.mkv"

            # Apply the zoom using FFmpeg's crop and scale filters
            ffmpeg -i "$INPUT_VIDEO" -vf "crop=${ZOOM_WIDTH}:${ZOOM_HEIGHT}:${ZOOM_X}:${ZOOM_Y},scale=1920:1080" "$output_file"

            echo "Video zoomed and saved as $output_file."
            ;;

        "Stabilization")
            echo "You chose the Stabilization option."

            # Determine the output file name for the stabilized video
            stabilized_output_file="${INPUT_VIDEO%.*}_stabilized.mkv"  # Adjusting the output format as needed

            # Perform stabilization using FFmpeg's vidstab filter
            ffmpeg -i "$INPUT_VIDEO" -vf vidstabtransform=smoothing=30:input="transforms.trf" "$stabilized_output_file"

            echo "Video stabilized and saved as $stabilized_output_file."
            ;;

        "Slo-mo")
            echo "You chose the Slo-mo option."

            # Prompt the user for the desired slow-motion factor (e.g., 2x, 3x, etc.)
            echo "Enter the slow-motion factor (e.g., 2 for 2x slow-motion, 3 for 3x slow-motion):"
            read SLOWMO_FACTOR
            : ${SLOWMO_FACTOR:=2}  # Default to 2x slow-motion if no input is provided

            # Determine the output file name for the slow-motion video
            slowmo_output_file="${INPUT_VIDEO%.*}_slowmo.mkv"  # Adjusting the output format as needed

            # Perform slow-motion effect using FFmpeg's setpts filter
            ffmpeg -i "$INPUT_VIDEO" -vf "setpts=${SLOWMO_FACTOR}*PTS" -an "$slowmo_output_file"

            echo "Video converted to ${SLOWMO_FACTOR}x slow-motion and saved as $slowmo_output_file."
            ;;

                "Basic Video Converter")
            echo "You chose the Basic Video Converter option."

            # Prompt the user for the desired output format
            echo "Select the output format (mp4, mkv, webm, avi, m4v):"
            read OUTPUT_FORMAT
            case "$OUTPUT_FORMAT" in
                mp4|mkv|webm|avi|m4v) ;;
                *) echo "Invalid format. Defaulting to mp4."
                   OUTPUT_FORMAT="mp4"
                   ;;
            esac

            # Determine the output file name based on the chosen format
            output_file="${INPUT_VIDEO%.*}.$OUTPUT_FORMAT"

            # Perform the conversion using FFmpeg
            ffmpeg -i "$INPUT_VIDEO" "$output_file"

            echo "Video converted to $OUTPUT_FORMAT format and saved as $output_file."
            ;;

         "Enhanced SVP Transformation")
            echo "You chose the Enhanced SVP Transformation option."

            # Prompt the user for the desired PTS adjustment value
            echo "Enter a value to adjust PTS for smoother playback (default is 1):"
            read PTS_VALUE
            : ${PTS_VALUE:=1}

            # Determine the input and output files for the VapourSynth script
            vs_input_file="${INPUT_VIDEO}"
            vs_output_file="${OUTPUT_VIDEO%.*}_svp.mkv"  # Adjusting the output format as needed

            # Invoke the VapourSynth script with the necessary parameters
            vspipe -y svpscript.py -i "${vs_input_file}" -o "${vs_output_file}" --pts "${PTS_VALUE}"

            echo "Video processed with adjusted PTS of ${PTS_VALUE} and saved to ${vs_output_file}."
            ;;

# After the transformations
echo "Processed video saved as $OUTPUT_VIDEO."

# Cleanup temporary files or scripts if any
# For example:
if [[ -f "$TEMP_VPY" ]]; then
    rm -f "$TEMP_VPY"
fi

echo "========================================"
echo "Processing Summary:"
echo "Input Video: $INPUT_VIDEO"
echo "Output Video: $OUTPUT_VIDEO"
echo "Transformation: $opt"
echo "========================================"
echo "Processing completed successfully!"
