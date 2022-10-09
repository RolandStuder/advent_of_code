class Coordinate
  @list = {}
  include Comparable

  attr_accessor :x, :y

  def self.new(x,y)
    x = x.to_i
    y = y.to_i
    # return existing object from list, if it exists
    return @list["#{x}_#{y}"] if @list["#{x}_#{y}"]
    super
  end

  def self.add_to_list(instance)
    @list["#{instance.x}_#{instance.y}"] = instance
  end

  def initialize(x,y)
    @x = x
    @y = y
    self.class.add_to_list(self)
  end

  def shares_axis_with?(other)
    horizontal_of(other) || vertical_of(other)
  end

  def horizontal_of?(other)
    other.y == y
  end

  def vertical_of?(other)
    other.x == x
  end

  def diagonal_of?(other)
    (other.x - x).abs == (other.y - y).abs
  end

  def coordinates_connecting(other, diagonals: true)
    if horizontal_of?(other) || vertical_of?(other) || (diagonals && diagonal_of?(other))
      delta_x = (other.x <=> x)
      delta_y = (other.y <=> y)

      coordinates = [self]
      loop do
        coordinates << Coordinate.new(coordinates.last.x + delta_x, coordinates.last.y + delta_y)
        return coordinates if coordinates.last == other
      end
    end

    []
  end

  def neighbours
    [
      Coordinate.new(x+1,y),
      Coordinate.new(x-1,y),
      Coordinate.new(x,y+1),
      Coordinate.new(x,y-1),
    ]
  end

  # to compare equality of coordinates
  def <=>(other)
    [x,y] <=> [other.x, other.y]
  end
end

