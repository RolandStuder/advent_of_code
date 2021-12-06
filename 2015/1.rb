# ruby -Ilib:test 2015/1.rb
require "minitest/autorun"
require "./lib/parsing_helper"

class FloorFinder
  def initialize(input)
    @input = input
  end

  def find_instructions
    @input.chars.count("(") - @input.chars.count(")")
  end

  def first_subfloor_index
    floor = 0
    @input.chars.each.with_index(1) do |char, index|
      floor += ((char == "(") ? 1 : -1)
      return index if floor.negative?
    end
  end
end


class Day1Test < Minitest::Test
  def test_example_input
  end
end

# PART 1

parsed = ParsingHelper.load(2015,1).lines.first

pp FloorFinder.new(parsed).find_instructions
pp FloorFinder.new(parsed).first_subfloor_index
