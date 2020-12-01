require 'pry'
require 'minitest'
require 'minitest/autorun'

class AsteroidMap
  attr_reader :grid, :positions, :destroyed_asteroids
  def initialize(data)
    @grid = parse(data)
    @positions = get_positions
    @destroyed_asteroids = []
  end

  def height
    @height ||= grid.size
  end

  def width
    @width ||= grid.first.size
  end

  def visible_asteroids_count(x,y)
    visible_asteroids(x,y).keys.size
  end

  def visible_asteroids(x,y)
    return false unless @positions.find_index([x,y])

    directions = {}
    positions.each do |asteroid|
      if asteroid != [x,y]
        deg = (Math.atan2(x - asteroid[0],y - asteroid[1]) * (180 / Math::PI)).round(5)
        if directions[deg]
          current = directions[deg]
          directions[deg] = closer([x,y],current,asteroid)
        else
          directions[deg] = asteroid
        end
      end
    end
    directions
  end

  def best_location
    location = []
    count = 0
    positions.each do |pos|
      new_count = visible_asteroids_count(pos[0], pos[1])
      if new_count > count
        count = new_count
        location = pos
      end
    end
    location
  end

  def destroy(x,y)
    @destroyed_asteroids << [x,y]
    positions - [x,y]
  end

  def destroy_asteroids_from(x,y)
    directions = visible_asteroids(x,y).keys.sort_by { |dir| (-dir + 360) % 360 } #I want to start at 0 not -179

    directions.each do |dir|
      x_2,y_2 = visible_asteroids(x,y)[dir]
      destroy(x_2,y_2)
    end
  end

  private

  def closer(org, one, two)
    delta_one = (org[0] - one[0]).abs + (org[1] - one[1]).abs 
    delta_two = (org[0] - two[0]).abs + (org[1] - two[1]).abs
    delta_one > delta_two ? two : one
  end

  def parse(data)
    rows = data.split("\n")
    rows.map do |row|
      row.chars.map do |char|
        char == "#" ? true : false
      end
    end
  end

  def get_positions
    arr = []
    @grid.each_with_index do |row, y|
      row.each_with_index do |asteroid, x|
        if asteroid
          arr << [x,y]
        end
      end
    end
    arr
  end
end


class AsteroidMapTests < Minitest::Test
  def test_map_parser
    data = ".#\n.."
    map = AsteroidMap.new(data)
    assert_equal [[false, true],[false, false]], map.grid
  end

  def test_positions_array
    data = ".#\n.."
    map = AsteroidMap.new(data)
    assert_equal [[1,0]], map.positions
  end

  def test_count_visible_asteroids
    data = ".#..#\n.....\n#####\n....#\n...##"
    # .7..7
    # .....
    # 67775
    # ....7
    # ...87
    map = AsteroidMap.new(data)
    assert_equal 7, map.visible_asteroids_count(1,0)
    assert_equal 6, map.visible_asteroids_count(0,2)
    assert_equal 8, map.visible_asteroids_count(3,4)
  end

  def test_large_example
    data = File.open("10_1.dat").readlines.join
    map = AsteroidMap.new(data)
    assert_equal 210, map.visible_asteroids_count(11,13)
    assert_equal [11,13], map.best_location
  end

  def test_returns_closer_asteroid
    data = "###"
    map = AsteroidMap.new(data)
    assert_equal [1,0], map.visible_asteroids(0,0).values.first
    assert_equal [1,0], map.visible_asteroids(2,0).values.first
  end

  def test_destroys_asteroid
    data = "###"
    map = AsteroidMap.new(data)
    map.destroy(1,0)
    assert_equal 1, map.destroyed_asteroids.count
    assert_equal [1,0], map.destroyed_asteroids.first
  end

  def test_destroys_asteroids_in_sweep
    data = File.open("10_1.dat").readlines.join
    map = AsteroidMap.new(data)
    map.destroy_asteroids_from(11,13)
    # The 1st asteroid to be vaporized is at 11,12.
    # The 2nd asteroid to be vaporized is at 12,1.
    # The 3rd asteroid to be vaporized is at 12,2.
    # The 10th asteroid to be vaporized is at 12,8.
    # The 20th asteroid to be vaporized is at 16,0.
    # The 50th asteroid to be vaporized is at 16,9.
    # The 100th asteroid to be vaporized is at 10,16.
    # The 199th asteroid to be vaporized is at 9,6.
    # The 200th asteroid to be vaporized is at 8,2.

    assert_equal [11,12], map.destroyed_asteroids.first
    assert_equal [12,1], map.destroyed_asteroids[1]
    assert_equal [16,9], map.destroyed_asteroids[49]
    assert_equal [8,2], map.destroyed_asteroids[199]
  end
end


data = File.open("10.dat").readlines.join
map = AsteroidMap.new(data)
best_location = map.best_location
puts "1:"
puts map.visible_asteroids_count(best_location[0], best_location[1])


# taking the shortcut, as my asteroid is in the first swipe

map.destroy_asteroids_from(best_location[0], best_location[1])
puts "2:"
puts map.destroyed_asteroids[199].inspect

