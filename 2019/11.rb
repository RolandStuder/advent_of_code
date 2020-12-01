# You'll need to build a new emergency hull painting robot.
# The robot needs to be able to move around on the grid of
# square panels on the side of your ship, detect the color
# of its current panel, and paint its current panel black
# or white. (All of the panels are currently black.)
#
# The Intcode program will serve as the brain of the robot.
# The program uses input instructions to access the robot's camera:
# - provide 0 if the robot is over a black panel or
# - 1 if the robot is over a white panel. Then, the program will output two values:
#
#  First, it will output a value indicating the color to paint the panel the robot is over:
#  - 0 means to paint the panel black, and
#  - 1 means to paint the panel white.
#
# Second, it will output a value indicating the direction the robot should turn:
# - 0 means it should turn left 90 degrees, and
# - 1 means it should turn right 90 degrees.
#  After the robot turns, it should always move forward exactly one panel. The robot starts facing up.
#

require 'colorize'
require_relative '11_test'
require_relative 'lib/int_code'

class Robot
  attr_reader :canvas
  def initialize(programm)
    @programm = IntCode.new(programm)
    @x, @y = 0,0
    @canvas = Canvas.new
    @direction = 0
  end

  def tile_color
    @canvas.color_at(@x, @y) || "black"
  end

  def perform
    output = [0]
    while output.size > 0 do
      @programm.input = (tile_color == "black") ? 0 : 1
      output = @programm.output
      color_to_paint = (output[0] == 0) ? "black" : "white"
      binding.pry if color_to_paint != "white" && color_to_paint != "black"
      direction_change = (output[1] == 0) ? 270 : 90
      @direction = (@direction + direction_change) % 360
      @canvas.paint(@x, @y, color_to_paint)
      move
    end
  end

  def move
    case @direction
    when 0
      @y += 1
    when 90
      @x += 1
    when 180
      @y -= 1
    when 270
      @x -= 1
    end
  end
end

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

programm = File.open("11.dat").readlines.join.split(",")
robot = Robot.new(programm)
robot.perform
puts robot.canvas.grid
robot.canvas.print
puts "Area covered (part 1)"
puts (robot.canvas.grid.flatten - [nil]).size - 1 #I don't know why - 1

robot = Robot.new(programm)
robot.canvas.paint(0,0, "white")
robot.perform
robot.canvas.print
puts "Part 2"
puts (robot.canvas.grid.flatten - [nil]).size - 1 #I don't know why - 1

