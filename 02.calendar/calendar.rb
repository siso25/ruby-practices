require 'date'

# 年と月を表示
year = Date.today.year
month = Date.today.month
puts "#{month.to_s}月 #{year.to_s}".center(20)

# 曜日を表示
days_of_week = %w(日 月 火 水 木 金 土)
puts days_of_week.join(" ")

# 月の最終日を取得する
first_date = Date.new(year, month, 1)
last_date = Date.new(year, month, -1)

# 開始位置を決める
width_of_day = 2
right_blank = 1
start_position = (width_of_day + right_blank) * first_date.wday

# 日付部分の表示
# 1日〜最終日までループ
(first_date..last_date).each do |date|
  # 右詰で出力
  if date.day == 1
    print date.day.to_s.rjust(start_position + width_of_day)
  else
    print date.day.to_s.rjust(width_of_day)
  end
  print " " * right_blank

  # 土曜日だったら改行
  saturday = 6
  if date.wday == saturday
    print "\n"
  end
end

puts "\n\n"
