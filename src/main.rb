require 'rubygems'
require 'bundler/setup'
require 'pipes'

ZIP_FILE_PATH = ENV[:input_file_path]
OUTPUT_NAME_PATH = ENV[:output_file_path] || '../output.jpg'
SLACK_API_TOKEN = ENV[:slack_api_token]
CHANNELS = ENV[:channels]

exit 1 unless validate_args(ZIP_FILE_PATH,
                            OUTPUT_NAME_PATH,
                            SLACK_API_TOKEN,
                            CHANNELS)
unzip_file ZIP_FILE_PATH
file_paths = extract_files_in_unziped_folder
file_paths = exclusion_like_files_by_file_size(file_paths)
exit 1 unless save_montage_image(file_paths, OUTPUT_NAME_PATH)
upload_file(OUTPUT_NAME_PATH, SLACK_API_TOKEN, CHANNELS)
exit 0
