#! /usr/bin/env ruby

# frozen_string_literal:true

def divide_and_ceil_remainder(divisor, dividend)
  return 0 if dividend.zero?

  quotient = divisor / dividend
  remainder = divisor % dividend

  remainder.zero? ? quotient : quotient + 1
end

def sort_by_output_order(file_name_list, max_column_number, max_low_number)
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

# ファイル名（フォルダ名）一覧の取得
pattern = '*'
file_or_directory_name_list = Dir.glob(pattern)
sorted_list = file_or_directory_name_list.sort

# 出力順に配列を並び替え
max_column_number = 3
max_low_number = divide_and_ceil_remainder(sorted_list.size, max_column_number)
sorted_by_output_order = sort_by_output_order(sorted_list, max_column_number, max_low_number)

# 出力
sorted_by_output_order.each_with_index do |item, idx|
  print item.ljust(24) if !item.nil?
  print "\n" if idx % max_column_number == max_column_number - 1
end

puts "\n"
