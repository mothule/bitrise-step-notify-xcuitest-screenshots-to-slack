require 'rubygems'
require 'bundler/setup'
require 'json'
require 'uri'
require 'httpclient'
require 'zip'
require 'mini_magick'

def validate_args(zip_file_path, output_name_path, slack_api_token, channels)
  return false if zip_file_path.empty?
  return false if output_name_path.empty?
  return false if slack_api_token.empty?
  return false if channels.empty?
  true
end

def unzip_file(file_path, opt = {})
  Zip::File.open(file_path) do |zip|
    zip.each do |entry|
      p entry.name if opt[:output_log]
      dir = File.join(dest, File.dirname(entry.name))
      FileUtils.mkpath(dir)
      zip.extract(entry, './' + entry.name) { true }
    end
  end
end

def extract_files_in_unziped_folder(filter = './Attachments/*')
  Dir.glob(filter)
end

def exclusion_like_files_by_file_size(files, threshold_byte_size = 1024)
  ss_path_list = []
  files.each do |f|
    if ss_path_list.empty?
      ss_path_list << f
    else
      diff_size = File.size(ss_path_list.last) - File.size(f)
      ss_path_list << f if diff_size.abs > threshold_byte_size
    end
  end
  ss_path_list
end

def save_montage_image(input_file_paths, output_file_name, opt = {})
  montage = MiniMagick::Tool::Montage.new
  input_file_paths.each { |f| montage << f }
  # default value is iPhone6 size(point)
  montage.geometry(opt[:geometry] || '320x568')
  montage << output_file_name
  montage.call
  File.exist?(output_file_name)
end

def upload_file(file_path, token, channels)
  url = 'https://slack.com/api/files.upload'
  client = HTTPClient.new
  boundary = '123412341234'
  File.open(file_path) do |file|
    post_data = { token: token, channels: channels, file: file }
    args = { 'content-type' => "multipart/form-data, boundary=#{boundary}" }
    client.post_content(url, post_data, args)
  end
end

exit 0
