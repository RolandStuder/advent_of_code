# ruby -Ilib:test 2021/5.rb
require "minitest/autorun"
require_relative "lib/parsing_helper"
require_relative "lib/coordinate"

class VentMap
  attr_accessor :grid

  def initialize(width = 10, height = 10)
    @grid =  Array.new(height, 0).map { |row| Array.new(width, 0)}
  end

  def draw_line(from, to, diagonals: false)
    from.coordinates_connecting(to, diagonals: diagonals).each do |coord|
      @grid[coord.y][coord.x] += 1
    end
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def values
    @grid.flatten
  end

  def dangerous_points_count
    values.count { |v| v >= 2 }
  end
end




class Day5 < Minitest::Test
  def test_example_input
    example_input = %{0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2}

    parsed = ParsingHelperDay5.new(example_input)
    assert_equal Coordinate.new(0,9), parsed.coordinate_pairs.first.first
    assert_equal Coordinate.new(0,3), Coordinate.new(0,2).coordinates_connecting(Coordinate.new(0,4))[1]
    map = VentMap.new
    parsed.coordinate_pairs.each do |coord_1, coord_2|
      map.draw_line(coord_1, coord_2)
    end

    puts map.to_s
    assert_equal 2, map.grid[9][2]
    assert_equal 5, map.dangerous_points_count
  end
end

class ParsingHelperDay5 < ParsingHelper
  def coordinate_pairs
    lines.map do |line|
      numbers = line.gsub("->", ",").split(",").map(&:to_i)
     [Coordinate.new(numbers[0], numbers[1]) , Coordinate.new(numbers[2], numbers[3])]
    end
  end
end


# PART 1
#
parsed_input = ParsingHelperDay5.load(5)
map = VentMap.new(1000, 1000)

parsed_input.coordinate_pairs.each do |coord_1, coord_2|
  map.draw_line(coord_1, coord_2)
end

pp map.dangerous_points_count

map = VentMap.new(1000, 1000)

parsed_input.coordinate_pairs.each do |coord_1, coord_2|
  map.draw_line(coord_1, coord_2, diagonals: true)
end

pp map.dangerous_points_count
