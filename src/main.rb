require 'rubygems'
require 'bundler/setup'
require 'pipes'

unless ARGV.size == 4
  p 'You should specify 4 arguments.'
  p 'argv 0 is slack api token'
  p 'argv 1 is slack channels'
  p 'argv 2 is input file path'
  p 'argv 3 is output file name'
  exit 1
end

SLACK_API_TOKEN = ARGV[0]
CHANNELS = ARGV[1]
ZIP_FILE_PATH = ARGV[2]
OUTPUT_NAME_PATH = "../#{ARGV[3]}".freeze

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
