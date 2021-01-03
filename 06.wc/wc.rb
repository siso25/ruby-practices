#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def no_option?(options)
  !options['l'] && !options['w'] && !options['c']
end

def output?(options, option_name)
  has_option = options[option_name]
  has_option || no_option?(options)
end

def error_message(file_name)
  "wc: #{file_name}: open: No such file or directory"
end

def count_chars(file)
  file.each.sum { |line| line.chars.size }
end

def count_words(file)
  file.each.sum { |line| line.split(/[\s \n]+/).size }
end

def count_lines(file)
  file.each.sum { |line| line[-1] == "\n" ? 1 : 0 }
end

def set_info(name: '', is_exist: true, lines: 0, words: 0, bytes: 0)
  {
    name: name,
    is_exist: is_exist,
    lines: lines,
    words: words,
    bytes: bytes
  }
end

def std_in_info(std_in)
  [] << set_info(lines: count_lines(std_in), words: count_words(std_in), bytes: count_chars(std_in))
end

def files_info(files_name)
  files_info = []
  files_name.each do |file_name|
    next files_info << set_info(name: file_name, is_exist: false) unless File.exist?(file_name)

    File.open(file_name, 'r') do |file|
      lines = file.map(&:itself)
      files_info << set_info(name: file_name, lines: count_lines(lines), words: count_words(lines), bytes: count_chars(lines))
    end
  end

  files_info
end

def calc_width(files_info, key, min_width)
  max_length = files_info.map { |file_info| file_info[key].to_s.length }.max
  min_width > max_length ? min_width : max_length
end

def calc_total(files_info, key)
  files_info.sum { |file| file[key] }
end

def width_list(files_info)
  set_info(lines: calc_width(files_info, :lines, 7),
           words: calc_width(files_info, :words, 7),
           bytes: calc_width(files_info, :bytes, 7))
end

def total_list(files_info)
  set_info(name: 'total',
           lines: calc_total(files_info, :lines),
           words: calc_total(files_info, :words),
           bytes: calc_total(files_info, :bytes))
end

def output_format(file, width_list, options)
  return error_message(file[:name]) unless file[:is_exist]

  padding = ' '
  output_format = []
  output_format << file[:lines].to_s.rjust(width_list[:lines]) if output?(options, 'l')
  output_format << file[:words].to_s.rjust(width_list[:words]) if output?(options, 'w')
  output_format << file[:bytes].to_s.rjust(width_list[:bytes]) if output?(options, 'c')
  output_format << file[:name] unless file[:name].empty?

  padding + output_format.join(padding)
end

def wc_command
  options = ARGV.getopts('lwc')
  files_info = ARGV.empty? ? std_in_info(readlines) : files_info(ARGV)
  width_list = width_list(files_info)

  files_info.each { |file| puts output_format(file, width_list, options) }
  puts output_format(total_list(files_info), width_list, options) if files_info.size >= 2
end

wc_command if __FILE__ == $PROGRAM_NAME
