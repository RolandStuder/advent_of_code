# ruby -Ilib:test 2021/9.rb
require "minitest/autorun"
require_relative "lib/parsing_helper"
require_relative "lib/grid"

binding.irb

class Day8Test < Minitest::Test
  def test_example_input
    example_input = %{2199943210
3987894921
9856789892
8767896789
9899965678}
    grid = Grid.new(example_input.split("\n").map { |map| map.chars.map(&:to_i)})
    assert_equal 2, grid.get(Coordinate.new(0,0))
    assert_equal [2, 9, 9].sort, grid.neighbours(Coordinate.new(1,0)).sort
    assert_equal 50, grid.coordinates.size
    assert_kind_of Coordinate, grid.coordinates.first
    low_point_coordinates = grid.coordinates.select { |coord| grid.neighbours(coord).all? { |value| value > grid.get(coord)}}
    low_point_values = grid.get([low_point_coordinates])
    risk_level_sum = low_point_values.map! { |v| v += 1}.sum
    assert_equal 15, risk_level_sum
  end

  def test_basin
    example_input = %{2199943210
3987894921
9856789892
8767896789
9899965678}
    grid = Grid.new(example_input.split("\n").map { |map| map.chars.map(&:to_i)})
    low_point_coordinates = grid.coordinates.select { |coord| grid.neighbours(coord).all? { |value| value > grid.get(coord)}}

    basin = Basin.new(low_point_coordinates.first, grid)
    assert_includes basin.coordinates, Coordinate.new(0,0)
    assert_includes basin.coordinates, Coordinate.new(1,0)
    assert_includes basin.coordinates, Coordinate.new(0,1)
  end
end

# part 1

grid = Grid.new(ParsingHelper.load(9).integer_lines)
low_point_coordinates = grid.coordinates.select { |coord| grid.neighbours(coord).all? { |value| value > grid.get(coord)}}
low_point_values = grid.get([low_point_coordinates])
risk_level_sum = low_point_values.map! { |v| v += 1}.sum
pp risk_level_sum

class Basin
  attr_reader :grid

  def initialize(coord, grid)
    @lowpoint = coord
    @grid = grid
  end

  def coordinates
    coordinates = [@lowpoint]
    visited = [@lowpoint]

    candidates = coordinates.map { |c| grid.neighbour_coordinates(c) }.flatten

    coordinates += candidates.select { |candidate|
      grid.neighbour_coordinates(candidate).all? { |neighbour_neighbour|
        next false if visited.include?(neighbour_neighbour)
        grid.get(neighbour_neighbour) > grid.get(candidate)
      }
      visited << candidate
    }
    new_candidates = coordinates.map { |c| grid.neighbour_coordinates(c) }.flatten

    coordinates
  end
end

