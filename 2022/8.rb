require "minitest/autorun"
require "./lib/parsing_helper"
require "./lib/coordinate"
require "./lib/grid"

class Forest < Grid
  def self.from_string(string)
    grid = Grid.new(string.split("\n").map{ |line| line.chars.map(&:to_i) })
    new(grid)
  end
end


class Day7Test < Minitest::Test
  TEST_INPUT = %{30373
25512
65332
33549
35390}

  def test_data_structure
    Forest.from_string(TEST_INPUT)
    binding.irb
  end
end

puts "Part 1:"


puts "Part 2:"


