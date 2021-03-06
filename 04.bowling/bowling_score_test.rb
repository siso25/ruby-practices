# frozen_string_literal: true

require 'minitest/autorun'
require './bowling_score'

class BowlingScoreTest < Minitest::Test
  def test_is_shotted_all_pins
    assert shotted_all_pins?('X')
    refute shotted_all_pins?('10')
    refute shotted_all_pins?('0')
    assert shotted_all_pins?(10)
    refute shotted_all_pins?(0)
  end

  def test_is_strike
    assert strike?([10, 0])
    refute strike?([4, 4])
    refute strike?([0, 10])
  end

  def test_is_spare
    assert spare?([4, 6])
    assert spare?([0, 10])
    refute spare?([4, 5])
    refute spare?([10, 0])
  end

  def test_separate_by_frame
    array1 = [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 6, 4, 5]
    assert_equal [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [6, 4, 5]], separate_by_frame(array1)
    array2 = [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 10, 10, 10]
    assert_equal [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 10, 10]], separate_by_frame(array2)
    array3 = [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 4, 5]
    assert_equal [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [4, 5]], separate_by_frame(array3)
  end

  def test_calc_strike_score
    frames1 = [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 4, 5]]
    assert_equal 20, calculate_strike_score(frames1, 6)
    assert_equal 24, calculate_strike_score(frames1, 9)
    frames2 = [[10, 0], [10, 0], [7, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 4, 5]]
    assert_equal 27, calculate_strike_score(frames2, 1)
  end

  def test_calc_spare_score
    frames1 = [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 4, 5]]
    assert_equal 17, calculate_spare_score(frames1, 4)
  end
end
