require 'pry'
require 'minitest'
require 'minitest/autorun'

class Map
  attr_reader :positions
  def initialize(string)
    @positions = transform_to_array(string)
  end

  def transform_to_array(string)
    lines = string.split
    lines.map do |line|
      line.chars.map { |pos| pos == "#" ? 1 : 0}
    end
  end

  def get(coord)
    x = coord[0] % width
    y = coord[1]
    @positions[y][x]
  end

  def tree_at?(coord)
    get(coord) == 1
  end

  def width
    @positions.first.size
  end

  def height
    @positions.size
  end
end

class Toboggan
  attr_reader :slope

  def initialize(slope = {x: 3, y: 1})
    @pos_x = 0
    @pos_y = 0
    @slope = slope
  end

  def move(slope: @slope)
    @pos_x += slope[:x]
    @pos_y += slope[:y]
    return @pos_x, @pos_y
  end
end

class Run
  attr_reader :tree_count
  def initialize(map, sled)
    @map = map
    @sled = sled
    @tree_count = 0
  end

  def perform
    moves_necessary = (@map.height / @sled.slope[:y]) - 1
    moves_necessary.times do
      new_position = @sled.move
      @tree_count += 1 if @map.tree_at?(new_position)
    end
    self
  end
end

class MapTests < Minitest::Test
EXAMPLE_INPUT = %{
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
}

  def test_map_from_example
    map = Map.new(EXAMPLE_INPUT)
    assert_equal 1, map.get([2,0])
    assert_equal 0, map.get([0,0])
    assert_equal 1, map.get([0,1])
  end

  def test_map_from_example_out_of_right
    map = Map.new(EXAMPLE_INPUT)
    assert_equal 1, map.get([2+11,0])
    assert_equal 0, map.get([0+11,0])
    assert_equal 1, map.get([0+11,1])
  end

  def test_count
    map = Map.new(EXAMPLE_INPUT)
    sled = Toboggan.new
    tree_count = 0
    (map.height - 1).times do
      new_position = sled.move
      tree_count += 1 if map.tree_at?(new_position)
    end
    assert 7, tree_count
  end

  def test_count_with_run
    map = Map.new(EXAMPLE_INPUT)
    sled = Toboggan.new
    run = Run.new(map, sled)
    run.perform
    assert 7, run.tree_count
  end
end


puts "SOLUTION 1"
puts Run.new(Map.new(File.read("3.dat")), Toboggan.new).perform.tree_count


slopes =  [
    {x: 1, y: 1},
    {x: 3, y: 1},
    {x: 5, y: 1},
    {x: 7, y: 1},
    {x: 1, y: 2},
]

puts "Solution 2"
map = Map.new(File.read("3.dat"))
puts (slopes.map do |slope|
  Run.new(map, Toboggan.new(slope)).perform.tree_count
end).reduce(&:*)
