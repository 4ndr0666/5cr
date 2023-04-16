import argparse
import os
import sys

from PIL import Image, ImageFilter

# List of available filters
FILTERS = {
    "BLUR": ImageFilter.BLUR,
    "CONTOUR": ImageFilter.CONTOUR,
    "DETAIL": ImageFilter.DETAIL,
    "EDGE_ENHANCE": ImageFilter.EDGE_ENHANCE,
    "EDGE_ENHANCE_MORE": ImageFilter.EDGE_ENHANCE_MORE,
    "EMBOSS": ImageFilter.EMBOSS,
    "FIND_EDGES": ImageFilter.FIND_EDGES,
    "SHARPEN": ImageFilter.SHARPEN,
    "SMOOTH": ImageFilter.SMOOTH,
    "SMOOTH_MORE": ImageFilter.SMOOTH_MORE
}

def apply_filter(input_file, output_file, filter_name):
    try:
        # Check if the filter is available
        if filter_name not in FILTERS:
            raise ValueError(f"Invalid filter name. Available filters: {', '.join(FILTERS.keys())}")

        # Open the input image file
        with Image.open(input_file) as img:
            # Apply the filter
            filtered_img = img.filter(FILTERS[filter_name])

            # Save the filtered image
            filtered_img.save(output_file)

        print(f"Filter '{filter_name}' applied and saved as {output_file}")
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description="Apply filters to images")
    parser.add_argument("input_file", help="Path to the input image file")
    parser.add_argument("output_file", help="Path to the output image file")
    parser.add_argument("filter_name", help="Name of the filter to apply")

    args = parser.parse_args()

    apply_filter(args.input_file, args.output_file, args.filter_name)

if __name__ == "__main__":
    main()
