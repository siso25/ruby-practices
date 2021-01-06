#! /usr/bin/env ruby

# frozen_string_literal:true

require 'optparse'
require 'etc'

def glob(pattern, directory_path, has_option_a)
  pattern_with_path = "#{directory_path}/#{pattern}"

  file_path_list =
    if has_option_a
      Dir.glob(pattern_with_path, File::FNM_DOTMATCH)
    else
      Dir.glob(pattern_with_path)
    end

  file_path_list.map { |file_path| File.basename(file_path) }
end

def sort(list, has_option_r)
  return list.sort.reverse if has_option_r

  list.sort
end

def file_type_for_output(file_type)
  {
    'file' => '-',
    'directory' => 'd',
    'link' => 'l'
  }[file_type]
end

def permission_for_output(permission_number)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[permission_number]
end

def last_six_month?(date)
  today = Time.now
  date.year == today.year && date.month > today.month - 6
end

def divide_and_ceil_remainder(divisor, dividend)
  return 0 if dividend.zero?

  quotient = divisor / dividend
  remainder = divisor % dividend

  remainder.zero? ? quotient : quotient + 1
end

def get_file_name(file_name, path, file)
  return file_name unless file.symlink?

  source_file = File.readlink("#{path}/#{file_name}")
  "#{file_name} -> #{source_file}"
end

def file_type_and_mode(type, file_mode)
  file_type = file_type_for_output(type)
  user_permission = permission_for_output(file_mode[0])
  group_permission = permission_for_output(file_mode[1])
  other_permission = permission_for_output(file_mode[2])

  file_type + user_permission + group_permission + other_permission
end

def calculate_width(array, unit, key = nil)
  max_width = 0
  array.each do |item|
    next if item.nil?

    width = key.nil? ? item.length : item[key].length
    max_width = width if width > max_width
  end

  divide_and_ceil_remainder(max_width, unit) * unit
end

def time_or_year(time)
  return time.strftime('%R') if last_six_month?(time)

  time.strftime('%Y')
end

def hash_file_info(file_name, path)
  file = File.lstat("#{path}/#{file_name}")
  file_mode = file.mode.to_s(8)[-3, 3]
  update_time = file.mtime

  {
    file_mode: file_type_and_mode(file.ftype, file_mode),
    link: file.nlink.to_s,
    owner: Etc.getpwuid(file.uid).name,
    group: Etc.getgrgid(file.gid).name,
    size: file.size.to_s,
    block: file.blocks,
    month: update_time.strftime('%-m'),
    day: update_time.strftime('%-d'),
    time: time_or_year(update_time),
    name: get_file_name(file_name, path, file)
  }
end

def hash_file_info_width(file_info)
  {
    file_mode: calculate_width(file_info, 1, :file_mode),
    link: calculate_width(file_info, 1, :link),
    owner: calculate_width(file_info, 1, :owner),
    group: calculate_width(file_info, 1, :group),
    size: calculate_width(file_info, 1, :size),
    month: calculate_width(file_info, 1, :month),
    day: calculate_width(file_info, 1, :day),
    time: calculate_width(file_info, 1, :time)
  }
end

def long_format(file_info, file_info_width_list)
  file_mode = file_info[:file_mode].ljust(file_info_width_list[:file_mode])
  link = file_info[:link].rjust(file_info_width_list[:link])
  owner = file_info[:owner].ljust(file_info_width_list[:owner])
  group = file_info[:group].ljust(file_info_width_list[:group])
  size = file_info[:size].rjust(file_info_width_list[:size])
  month = file_info[:month].rjust(file_info_width_list[:month])
  day = file_info[:day].rjust(file_info_width_list[:day])
  time = file_info[:time].rjust(file_info_width_list[:time])
  name = file_info[:name]

  "#{file_mode}  #{link} #{owner}  #{group}  #{size} #{month} #{day} #{time} #{name}"
end

def sort_by_wrapping_output_order(file_name_list, max_column_number, max_low_number)
  # eachで順番に出力すれば良い並び順にする
  sorted_list = []

  file_name_list.each_with_index do |file_name, idx|
    column_index = idx / max_low_number
    low_index = idx % max_low_number
    index_for_output = column_index + (low_index * max_column_number)

    sorted_list[index_for_output] = file_name
  end

  sorted_list
end

def output_short_format(file_name_list)
  max_column_number = 3
  max_low_number = divide_and_ceil_remainder(file_name_list.size, max_column_number)
  sorted_by_output_order = sort_by_wrapping_output_order(file_name_list, max_column_number, max_low_number)

  last_index = sorted_by_output_order.size - 1
  width = calculate_width(sorted_by_output_order, 8)
  sorted_by_output_order.each_with_index do |item, idx|
    print item.ljust(width) unless item.nil?
    # 1行だけのときは改行しない
    next if idx == last_index

    print "\n" if idx % max_column_number == max_column_number - 1
  end

  puts "\n"
end

def output_long_format(file_name_list, directory_path, is_dir)
  # ファイルの詳細情報を取得
  file_info_list = []
  file_name_list.each do |file_name|
    file_info_list << hash_file_info(file_name, directory_path)
  end

  if is_dir
    total_block = 0
    file_info_list.each { |file| total_block += file[:block] }
    puts "total #{total_block}"
  end

  file_info_width_list = hash_file_info_width(file_info_list)
  file_info_list.each do |file_info|
    puts long_format(file_info, file_info_width_list)
  end
end

# コマンドライン引数の取得
options = ARGV.getopts('alr')
path = ARGV[0]
absolute_path = path.nil? ? Dir.pwd : File.expand_path(path)
abort("ls: #{path}: No such file or directory") unless File.exist?(absolute_path)

# ファイル一覧の取得
is_dir = File.directory?(absolute_path)
pattern = is_dir ? '*' : File.basename(absolute_path)
directory_path = is_dir ? absolute_path : File.dirname(absolute_path)
file_name_list = glob(pattern, directory_path, options['a'])
sorted_list = sort(file_name_list, options['r'])

# 画面出力
if options['l']
  output_long_format(sorted_list, directory_path, is_dir)
else
  output_short_format(sorted_list)
end
