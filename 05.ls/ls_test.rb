# frozen_string_literal:true

require 'minitest/autorun'
require './ls'

class LsTest < Minitest::Test
  def test_sort_by_output_order
    # (列数 × 行数) = 要素数
    assert_equal ['1', '3', '5', '2', '4', '6'], sort_by_output_order(['1', '2', '3', '4', '5', '6'], 3, 2)

    # (列数 × 行数) > 要素数
    assert_equal ['1', '4', '7', '2', '5', nil, '3', '6'], sort_by_output_order(['1', '2', '3', '4', '5', '6', '7'], 3, 3)
  end

  def test_divide_and_ceil_remainder
    # 余り = 0
    assert_equal 2, divide_and_ceil_remainder(6, 3)

    # 余り > 0
    assert_equal 3, divide_and_ceil_remainder(7, 3)

    # 0除算
    assert_equal 0, divide_and_ceil_remainder(6, 0)
  end
end
