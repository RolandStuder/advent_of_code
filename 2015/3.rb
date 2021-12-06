# ruby -Ilib:test 2015/1.rb
require "minitest/autorun"
require "./lib/parsing_helper"


class HouseGrid
  attr_reader :positions

  def self.follow_instructions(string)
    grid = new
    string.chars.each do |char|
      case char
      when "<"
        grid.west
      when ">"
        grid.east
      when "^"
        grid.north
      when "v"
        grid.south
      end
    end
    grid
  end

  def self.follow_ever_other_instruction(string)
    grid_one = new
    grid_two = new
    string.chars.each.with_index do |char, index|
      if index.even?
        grid = grid_one
      else
        grid = grid_two
      end

      case char
      when "<"
        grid.west
      when ">"
        grid.east
      when "^"
        grid.north
      when "v"
        grid.south
      end
    end
    (grid_one.positions.keys + grid_two.positions.keys).uniq.count
  end

  def initialize
    @positions = Hash.new(0)
    @x = 0
    @y = 0
    mark_current
  end

  def north
    @y -= 1
    mark_current
  end

  def south
    @y += 1
    mark_current
  end

  def west
    @x -= 1
    mark_current
  end

  def east
    @x += 1
    mark_current
  end

  private

  def mark_current
    @positions[ "#{@x}_#{@y}"] += 1
  end

end

class Day2Test < Minitest::Test
  def test_example_input
    assert_equal 2, HouseGrid.follow_instructions(">").positions.size
    assert_equal 4, HouseGrid.follow_instructions("^>v<").positions.size
  end
end

pp HouseGrid.follow_instructions(ParsingHelper.load(2015, 3).lines.first).positions.size
pp HouseGrid.follow_ever_other_instruction(ParsingHelper.load(2015, 3).lines.first)
