require 'pry'
require 'minitest'
require "minitest/autorun"


RANGE = "183564-657474"

start, stop = RANGE.split("-").map(&:to_i)

class SolverTests < Minitest::Test
  def test_two_adjacenct_digits_next_to_each_other
    assert_equal true, Password.new(122345).adjacent_digits?
    assert_equal false, Password.new(123456).adjacent_digits?
    assert_equal false, Password.new(123789).adjacent_digits?
  end

  def test_ever_increasing
    assert_equal true, Password.new(136789).digits_increase?
    assert_equal true, Password.new(111123).digits_increase?
    assert_equal true, Password.new(135679).digits_increase?
    assert_equal false, Password.new(130789).digits_increase?
    assert_equal false, Password.new(223450).digits_increase?
  end

  def test_combined
    assert_equal true,  Password.new(111111).candidate?
    assert_equal false,  Password.new(223450).candidate?
    assert_equal false,  Password.new(123789).candidate?
  end

  def test_no_more_than_two_adjacent
    assert_equal true, Password.new(112233).adjacent_digits_no_part_of_larger_group?
    assert_equal false, Password.new(123444).adjacent_digits_no_part_of_larger_group?
    assert_equal true, Password.new(111122).adjacent_digits_no_part_of_larger_group?
    assert_equal false, Password.new(111222).adjacent_digits_no_part_of_larger_group?
  end

  def test_adjacent_group_lengths
    assert_equal [2,2,2], Password.new(112233).adjacent_group_lengths
    assert_equal [7], Password.new(1111111).adjacent_group_lengths
    assert_equal [1,1,1,3], Password.new(123444).adjacent_group_lengths
    assert_equal [3,3], Password.new(111222).adjacent_group_lengths
    assert_equal [1,1,1,1], Password.new(1234).adjacent_group_lengths
    assert_equal [4,2], Password.new(111133).adjacent_group_lengths
    assert_equal [4,2], Password.new(111144).adjacent_group_lengths
    assert_equal [4,2], Password.new(111122).adjacent_group_lengths
  end

  def test_combined_two
    assert_equal true, Password.new(112233).candidate_part_2?
    assert_equal false, Password.new(123444).candidate_part_2?
    assert_equal true, Password.new(111122).candidate_part_2?
    assert_equal false, Password.new(111111).candidate_part_2?
    assert_equal false, Password.new(221111).candidate_part_2?
    assert_equal false, Password.new(121121).candidate_part_2?
    assert_equal false, Password.new(111222).candidate_part_2?
  end
end

## Step 1 Solver

class Password
  def initialize(number)
    @number = number
  end

  def adjacent_digits?
    digits.each_with_index do |digit, i|
      return true if digit == digits[i+1]
    end
    false
  end

  def digits_increase?
    digits.each_with_index do |digit, i|
      return true if i == digits.size-1
      return false if digit > digits[i+1]
    end
  end

  def adjacent_digits_no_part_of_larger_group?
    adjacent_group_lengths.include? 2
  end

  def candidate?
    adjacent_digits? && 
      digits_increase?
  end

  def candidate_part_2?
    adjacent_digits? && 
      digits_increase? && 
      adjacent_digits_no_part_of_larger_group?
  end

  def adjacent_group_lengths
    memo = []
    position = 0
    count = 1
    while position + count <= digits.length
      while digits[position+count] == digits[position]
        count += 1
      end
      memo << count
      position += count
      count = 1
    end
    memo
  end

  private

  def digits
    @digits ||= @number.digits.reverse
  end
end

class Solver
  def self.result(start, stop)
    (start..stop).count { |number| Password.new(number).candidate? }
  end
end

class Solver_2 < Solver
  def self.result(start, stop)
    (start..stop).count { |number| Password.new(number).candidate_part_2? }
  end
end

puts "*" * 40
puts "Part 1:"
puts Solver.result(start,stop)

puts "*" * 40
puts "Part 2:"
puts Solver_2.result(start,stop)

