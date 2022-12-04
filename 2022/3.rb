require "minitest/autorun"
require "./lib/parsing_helper"

def common_element(string)
  (string.chars[0..(string.size/2-1)] & string.chars[(string.size/2)..]).first
end

def value(char)
  (("a".."z").zip((1..26)) + ("A".."Z").zip((27..52))).to_h[char]
end

def value_of_line(line)
  value(common_element(line))
end

class Day3Test < Minitest::Test
  TEST_INPUT = %{vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw}

  def test_part_example
    lines = TEST_INPUT.split("\n")
    line = lines.first
    assert_equal "p", common_element(line)
    assert_equal 16, value("p")
    assert_equal 16, value_of_line(line)
  end
end

puts "Part 1:"
puts ParsingHelper.load(2022, 3).lines.map { |line| value_of_line(line) }.sum

puts "Part 2:"

puts ParsingHelper.load(2022, 3).lines.each_slice(3).map { |group| value((group[0].chars & group[1].chars & group[2].chars).first) }.sum
