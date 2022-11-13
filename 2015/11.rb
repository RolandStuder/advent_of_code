require "minitest/autorun"
require "./lib/parsing_helper"

class Password
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def valid?
    no_confusing_letters? && two_distinct_pairs? && three_straight_increases?
  end

  def three_straight_increases?
    @value.chars.each.with_index(1) do |char, index|
      return true if char.succ == @value[index] && char.succ.succ == @value[index+1]
    end

    false
  end

  def no_confusing_letters?
    (@value.chars & ["i", "o", "l"]).none?
  end

  def two_distinct_pairs?
    groups = @value.chars.slice_when { |i,j| i != j}.select { |group| group.size > 1 }
    groups.map(&:first).uniq.size >= 2
  end

  def succ
    @value = @value.succ
  end

  def valid_successor
    succ
    while !valid?
      succ
    end
    value
  end
end


class Day11Test < Minitest::Test
  def test_part_example
    # hijklmmn meets the first requirement (because it contains the straight hij) but fails the second requirement requirement (because it contains i and l).
    pw = Password.new("hijklmmn")
    assert_equal false, pw.valid?
    assert_equal true, pw.three_straight_increases?
    assert_equal false, pw.no_confusing_letters?

    # abbceffg meets the third requirement (because it repeats bb and ff) but fails the first requirement.
    pw = Password.new("abbceffg")
    assert_equal false, pw.valid?
    assert_equal false, pw.three_straight_increases?
    assert_equal true, pw.no_confusing_letters?

    # abbcegjk fails the third requirement, because it only has one double letter (bb).
    pw = Password.new("abbcegjk")
    assert_equal false, pw.valid?
    assert_equal false, pw.three_straight_increases?
    assert_equal true, pw.no_confusing_letters?
    assert_equal false, pw.two_distinct_pairs?


    # The next password after ghijklmn is ghjaabcc, because you eventually skip all the passwords that start with ghi..., since i is not allowed.
    pw = Password.new("abcdffaa")
    assert_equal true, pw.three_straight_increases?
    assert_equal true, pw.no_confusing_letters?
    assert_equal true, pw.two_distinct_pairs?
    assert_equal true, pw.valid?

    # The next password after abcdefgh is abcdffaa.
    pw = Password.new("abcdefgh")
    assert_equal "abcdffaa", pw.valid_successor
  end
end

puts "PART: 1"
puts Password.new("vzbxkghb").valid_successor

puts "PART: 2"
puts Password.new("vzbxxyzz").valid_successor
