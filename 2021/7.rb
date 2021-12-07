# ruby -Ilib:test 2021/7.rb
require "minitest/autorun"
require_relative "lib/parsing_helper"

class Distribution
  def initialize(numbers)
    @numbers = numbers
  end

  def cheapest_fuel
    ((@numbers.min)..(@numbers.max)).map do |position|
      @numbers.map { |number| (number-position).abs}.sum
    end.min
  end

  def cheapest_fuel_with_increasing_rate
    ((@numbers.min)..(@numbers.max)).map do |position|
      @numbers.map { |number|
        delta = (number-position).abs
        delta * (delta + 1) / 2
      }.sum
    end.min
  end

end


class Day7Test < Minitest::Test
  def test_example_input
    example_input = %{16,1,2,0,4,2,7,1,2,14}

    numbers = example_input.split(",").map(&:to_i)
    distribution = Distribution.new(numbers)
    assert_equal 37, distribution.cheapest_fuel
    assert_equal 168, distribution.cheapest_fuel_with_increasing_rate
  end
end

# Part 1

numbers = ParsingHelper.load(7).integers
distribution = Distribution.new(numbers)
pp distribution.cheapest_fuel
pp distribution.cheapest_fuel_with_increasing_rate
