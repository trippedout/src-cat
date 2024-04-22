#!/bin/sh

# SrcCat
# _._     _,-'""`-._
# (,-.`._,'(       |\`-/|
#     `-.-' \ )-`( , o o)
#           `-    \`_`"'-
# A simple script to download a github repository and grab all the text files of a given directory recursively.
# This is a helper script meant to concatenate code docs into a single file for ingestion into an LLM.

# TODO: update this to something *~fancy~*
is_text_file() {
    mime_type=$(file --mime-type -b "$1")
    case "$mime_type" in # very basic mime check
        text/*) return 0 ;;
        *) return 1 ;;
    esac
}

process_files() {
    for file in "$1"/*
    do
        if [ -d "$file" ]; then
            # If the item is a directory, recursively process its contents
            process_files "$file"
        elif [ -f "$file" ] && is_text_file "$file"; then
            # If the item is a file and contains text, append its contents to the output file
            cat "$file" >> "$output_file"
            echo >> "$output_file"  # Add a newline after each file
        fi
    done
}

# Prompt the user for the GitHub URL
read -p "Enter the GitHub repository URL: " github_url

# Extract the repository URL and target path from the provided URL
repo_url=$(echo "$github_url" | sed -E 's|(https://github.com/[^/]+/[^/]+)/.*|\1|')
target_path=$(echo "$github_url" | sed -E 's|https://github.com/[^/]+/[^/]+/tree/[^/]+/(.*)|\1|')

# Extract the repository and folder names for the default filename
repo_name=$(echo "$repo_url" | sed -E 's|https://github.com/[^/]+/([^/]+).*|\1|')
folder_name=$(echo "$target_path" | tr '/' '-')
default_filename="${repo_name}-${folder_name}.txt"

# Prompt the user for the output file name
read -p "Enter the output file name (default: $default_filename): " user_filename

# Set output file to user input or default
output_file=${user_filename:-$default_filename}

# Create a temporary directory
temp_dir=$(mktemp -d)

# Clone the GitHub repository into the temporary directory
git clone "$repo_url.git" "$temp_dir"

# Remove the output file if it already exists
rm -f "$output_file"

# Set the output file's MIME type to text/plain
echo "" > "$output_file"
# file -m "$output_file" > /dev/null

# Start processing files recursively from the target path within the cloned repository
echo "processing $temp_dir/$target_path"
process_files "$temp_dir/$target_path"

# Remove the temporary directory
rm -rf "$temp_dir"

echo "Concatenation complete. Output file: $output_file"