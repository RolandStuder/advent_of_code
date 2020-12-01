class Canvas
  attr_accessor :grid
  def initialize
    @grid = []
    @offset_x = 0
    @offset_y = 0
  end

  def paint(x,y,color="white")
    x,y = normalize(x,y)
    @grid[y] ||= []
    @grid[y][x] = color
  end

  def print
    @grid.reverse.each do |row|
      print_row row
    end
    true
  end

  def color_at(x,y)
    x,y = normalize(x,y)
    if @grid[y]
      @grid[y][x]
    else
      return nil
    end
  end

  private

  def print_row(row)
    row = [] if row.nil?
    colorized_row = row.each.map do |color|
      color ||= "black"
      "  ".colorize(:background => color.to_sym)
    end.join
    puts colorized_row
  end

  def normalize(x,y)
    if y < 0 && y.abs > @offset_y
      delta = y.abs - @offset_y
      @grid = Array.new(delta) + @grid
      @offset_y = y.abs
    end
    if x < 0 && x.abs > @offset_x
      delta = x.abs - @offset_x
      @offset_x = x.abs
      delta_array = Array.new(delta)
      @grid.map! do |row|
        new_row = delta_array + row
      end
    end
    [x + @offset_x, y + @offset_y]
  end
end
