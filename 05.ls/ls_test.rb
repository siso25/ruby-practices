# frozen_string_literal:true

require 'minitest/autorun'
require './ls'

class LsTest < Minitest::Test
  def test_glob
    assert_equal Dir.glob('*'), glob('*', Dir.pwd, false)
    assert_equal Dir.glob('*', File::FNM_DOTMATCH), glob('*', Dir.pwd, true)
  end

  def test_sort
    array = ['2', '1', '4', '5', '3']
    assert_equal ['1', '2', '3', '4', '5'], sort(array, false)
    assert_equal ['5', '4', '3', '2', '1'], sort(array, true)
  end

  def test_file_type_for_output
    assert_equal '-', file_type_for_output('file')
    assert_equal 'd', file_type_for_output('directory')
    assert_equal 'l', file_type_for_output('link')
  end

  def test_permission_for_output
    assert_equal '---', permission_for_output('0')
    assert_equal '--x', permission_for_output('1')
    assert_equal '-w-', permission_for_output('2')
    assert_equal 'r--', permission_for_output('4')
    assert_equal 'rwx', permission_for_output('7')
  end

  def test_last_six_month
    assert last_six_month?(Time.new(2020, 7, 1))
    refute last_six_month?(Time.new(2020, 6, 30))
  end

  def test_divide_and_ceil_remainder
    assert_equal 2, divide_and_ceil_remainder(6, 3)
    assert_equal 3, divide_and_ceil_remainder(7, 3)
    assert_equal 0, divide_and_ceil_remainder(6, 0)
  end

  def test_get_file_name
    assert_equal 'test1.txt', get_file_name('test1.txt', './test', File.lstat('./test/test1.txt'))
    assert_equal 'test1_link -> test1.txt', get_file_name('test1_link', './test', File.lstat('./test/test1_link'))
  end

  def test_sort_by_wrapping_output_order
    # (列数 × 行数) = 要素数
    assert_equal ['1', '3', '5', '2', '4', '6'], sort_by_wrapping_output_order(['1', '2', '3', '4', '5', '6'], 3, 2)
    # (列数 × 行数) > 要素数
    assert_equal ['1', '4', '7', '2', '5', nil, '3', '6'], sort_by_wrapping_output_order(['1', '2', '3', '4', '5', '6', '7'], 3, 3)
  end
end
