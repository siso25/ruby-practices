#! /usr/bin/env ruby

# frozen_string_literal:true

require 'optparse'

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

def divide_and_ceil_remainder(divisor, dividend)
  return 0 if dividend.zero?

  quotient = divisor / dividend
  remainder = divisor % dividend

  remainder.zero? ? quotient : quotient + 1
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

# コマンドライン引数の取得
options = ARGV.getopts('alr')

# ファイル名（フォルダ名）一覧の取得
pattern = '*'
full_path = Dir.pwd
file_name_list = glob(pattern, full_path, options['a'])

sorted_list = sort(file_name_list, options['r'])

# 出力順に配列を並び替え
max_column_number = 3
max_low_number = divide_and_ceil_remainder(sorted_list.size, max_column_number)
sorted_by_output_order = sort_by_wrapping_output_order(sorted_list, max_column_number, max_low_number)

# 画面出力
sorted_by_output_order.each_with_index do |item, idx|
  print item.ljust(24) if !item.nil?
  print "\n" if idx % max_column_number == max_column_number - 1
end

puts "\n"
