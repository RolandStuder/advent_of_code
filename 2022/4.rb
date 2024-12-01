require "minitest/autorun"
require "./lib/parsing_helper"

def covered_range?(string)
  first, second = string.split(",").map{ _1.split("-")}
  range_one = Range.new(first[0].to_i, first[1].to_i)
  range_two = Range.new(second[0].to_i, second[1].to_i)
  range_one.cover?(range_two) || range_two.cover?(range_one)
end

def overlap?(string)
  first, second = string.split(",").map{ _1.split("-")}
  range_one = Range.new(first[0], first[1])
  range_two = Range.new(second[0], second[1])
  range_one.each do |num|
    return true if range_two.include?(num)
  end

  false
end

class Day4Test < Minitest::Test
  TEST_INPUT = %{2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8}

  def test_part_example
    lines = TEST_INPUT.split("\n")
    assert_equal 2, lines.map { |line| covered_range?(line) }.count(true)
    assert_equal 4, lines.map { |line| overlap?(line) }.count(true)
  end
end

puts "Part 1:"
puts  ParsingHelper.load(2022, 4).lines.map { |line| covered_range?(line) }.count(true)


puts "Part 2:"

puts  ParsingHelper.load(2022, 4).lines.map { |line| overlap?(line) }.count(true)
