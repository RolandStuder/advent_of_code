require "minitest/autorun"
require "./lib/parsing_helper"

class Elf
  attr_reader :foods

  def initialize
    @foods = []
  end

  def total_calories
    foods.sum
  end

  def add_food(calories)
    @foods << calories.to_i
  end
end

class Day1Test < Minitest::Test
  TEST_INPUT = %{
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
  }

  def test_part_example
    elves = TEST_INPUT.split("\n\n").map do |calory_group|
      elf = Elf.new
      calory_group.split("\n").each do |food|
        elf.add_food(food)
      end
      elf
    end
    assert_equal 24000, elves.map(&:total_calories).max
  end
end

elves = ParsingHelper.load(2022, 1).raw.split("\n\n").map do |calory_group|
  elf = Elf.new
  calory_group.split("\n").each do |food|
    elf.add_food(food)
  end
  elf
end

puts "PART 1:"
puts elves.map(&:total_calories).max

puts "PART 2:"
puts elves.map(&:total_calories).sort.reverse.first(3).sum

