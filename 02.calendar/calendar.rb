#!/usr/bin/env ruby
require 'date'
require 'optparse'

def is_positive_integer(string)
  if !string.nil? && string.match?(/\d+/) && string.to_i > 0
    return true
  end

  false
end

def is_within_range_of_month(str_month)
  month = str_month.to_i
  january = 1
  december = 12
  if january <= month && month <= december
    return true
  end
  false
end

def calculate_start_position(first_date)
  width_of_day = 2
  right_blank = 1
  start_position = (width_of_day + right_blank) * first_date.wday
end


# 年と月の表示
options = ARGV.getopts("y:", "m:")
option_year = options["y"]
option_month = options["m"]

if is_positive_integer(option_year) 
  year = option_year.to_i
else
  year = Date.today.year
end

if is_positive_integer(option_month) && is_within_range_of_month(option_month)
  month = option_month.to_i
else
  month = Date.today.month
end

puts "#{month.to_s}月 #{year.to_s}".center(20)

# 曜日を表示
days_of_week = %w(日 月 火 水 木 金 土)
puts days_of_week.join(" ")

# 日付部分の表示
first_date = Date.new(year, month, 1)
last_date = Date.new(year, month, -1)

(first_date..last_date).each do |date|
  blank = " "
  if date.day == 1
    print blank * calculate_start_position(date)
  end
  print date.day.to_s.rjust(2) + blank

  saturday = 6
  if date.wday == saturday
    print "\n"
  end
end

puts "\n\n"
