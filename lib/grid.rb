require_relative 'coordinate'

# only support positive x,y coordinates
class Grid
  def self.with_size(width, height, default_value: nil)
    row = -> { Array.new(width) {
      if default_value.respond_to?(:call)
        default_value.call
      else
        default_value
      end
    } }

    grid = Array.new(height) { row.call }
    new(grid)
  end

  def initialize(two_dimensional_array)
    @grid = two_dimensional_array
  end

  def to_s
    "Grid#{hash}"
  end

  def get(coord)
    if coord.is_a? Array
      return coord.map { |single| get(single)}.flatten
    end

    return nil if coord.y.negative? || coord.x.negative?
    return nil if coord.y >= @grid.size

    @grid[coord.y][coord.x]
  end

  def coordinates
    coords = []
    @grid.each_with_index do |line, y,|
      line.each_with_index do |_value, x|
        coords << Coordinate.new(x,y)
      end
    end
    coords
  end

  def neighbours(coord)
    neighbour_coordinates(coord).map { |neighbour|
      get(neighbour)
    }.compact
  end

  def neighbour_coordinates(coord)
    coord.neighbours.select { |c| get(c) }
  end

  # will return every value from the square withing those coordinates
  def slice(from, to)
    (from.y..to.y).each.with_object([]) do |y, values|
      (from.x..to.x).each do |x|
        values << get(Coordinate.new(x,y))
      end
    end
  end
end
