# frozen_string_literal: true

require 'minitest/autorun'
require './wc'

class WcTest < Minitest::Test
  def test_is_no_option
    assert no_option?({ 'l' => false, 'w' => false, 'c' => false })
    refute no_option?({ 'l' => true, 'w' => false, 'c' => false })
  end

  def test_is_output
    assert output?({ 'l' => true, 'w' => false, 'c' => false }, 'l')
    assert output?({ 'l' => false, 'w' => false, 'c' => false }, 'l')
    refute output?({ 'l' => false, 'w' => true, 'c' => true }, 'l')
  end

  def test_error_message
    assert_equal 'wc: test.txt: open: No such file or directory', error_message('test.txt')
  end

  def test_count_chars
    file = File.new('test/test1.txt')
    assert_equal 19, count_chars(file)
    file.close
  end

  def test_count_words
    file = File.new('test/test1.txt')
    assert_equal 4, count_words(file)
    file.close
  end

  def test_count_lines
    file = File.new('test/test1.txt')
    assert_equal 3, count_lines(file)
    file.close
  end

  def test_set_info
    file_name = 'test/test1.txt'
    assert_equal({ name: 'test/test1.txt', is_exist: true, lines: 3, words: 4, bytes: 19 }, set_info(name: file_name, lines: 3, words: 4, bytes: 19))
  end

  def test_std_in_info
    str = %W[test\n test\n test]
    assert_equal [{ name: '', is_exist: true, lines: 2, words: 3, bytes: 14 }], std_in_info(str)
  end

  def test_files_info
    files_name = ['test/test1.txt', 'test/test2.txt', 'test/test3.txt']
    assert_equal [{ name: 'test/test1.txt', is_exist: true, lines: 3, words: 4, bytes: 19 },
                  { name: 'test/test2.txt', is_exist: true, lines: 4, words: 8, bytes: 40 },
                  { name: 'test/test3.txt', is_exist: false, lines: 0, words: 0, bytes: 0 }], files_info(files_name)
  end

  def test_calc_width
    array = [{ name: 'a', lines: 1 }, { name: 'bc', lines: 100 }, { name: 'def', lines: 10_000 }]
    assert_equal 4, calc_width(array, :name, 4)
    assert_equal 5, calc_width(array, :lines, 4)
  end

  def test_calc_total
    array = [{ lines: 1, words: -2, bytes: 0 }, { lines: 10, words: -20, bytes: 0 }, { lines: 100, words: -200, bytes: 0 }]
    assert_equal 111, calc_total(array, :lines)
    assert_equal(-222, calc_total(array, :words))
    assert_equal 0, calc_total(array, :bytes)
  end

  def test_output_format
    file = { name: 'test/test1.txt', is_exist: true, lines: 3, words: 4, bytes: 19 }
    width_list = { name: '', is_exist: true, lines: 7, words: 7, bytes: 7 }
    assert_equal '       3       4      19 test/test1.txt', output_format(file, width_list, { 'l' => true, 'w' => true, 'c' => true })
    assert_equal '       3       4      19 test/test1.txt', output_format(file, width_list, { 'l' => false, 'w' => false, 'c' => false })
    assert_equal '       3 test/test1.txt', output_format(file, width_list, { 'l' => true, 'w' => false, 'c' => false })
    assert_equal '       4 test/test1.txt', output_format(file, width_list, { 'l' => false, 'w' => true, 'c' => false })
    assert_equal '      19 test/test1.txt', output_format(file, width_list, { 'l' => false, 'w' => false, 'c' => true })
  end
end
