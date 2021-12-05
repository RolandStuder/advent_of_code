class Coordinate
  include Comparable

  attr_accessor :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def shares_axis_with(other)
    horizontal_of(other) || vertical_of(other)
  end

  def horizontal_of(other)
    other.y == y
  end

  def vertical_of(other)
    other.x == x
  end

  def coordinates_connecting(other)
    if horizontal_of(other)
      x_values = x <= other.x ? x.upto(other.x) : x.downto(other.x)
      return x_values.map { |x_value| Coordinate.new(x_value, y) }
    end

    if vertical_of(other)
      y_values = y <= other.y ? y.upto(other.y) : y.downto(other.y)
      return y_values.map { |y_value| Coordinate.new(x, y_value) }
    end

    return []
  end

  # to compare equality of coordinates
  def <=>(other)
    [x,y] <=> [other.x, other.y]
  end
end

