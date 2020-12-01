now = Time.now

require 'pry'
require 'colorize'
require 'minitest'
require "minitest/autorun"


PUZZLE_INPUT = File.open('3.dat').readlines.map(&:strip)

## STEP 1 Tests

class SolverTests < Minitest::Test
  def test_solver
    wire_1 = Wire.new("R8,U5,L5,D3")
    wire_2 = Wire.new("U7,R6,D4,L4")
    assert_equal 6, Solver.result(wire_1, wire_2)
  end

  def test_distance
    wire_3 = Wire.new("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    wire_4 = Wire.new("U62,R66,U55,R34,D71,R55,D58,R83")

    assert_equal 159, Solver.result(wire_3, wire_4)

    wire_5 = Wire.new("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
    wire_6 = Wire.new("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")

    assert_equal 135, Solver.result(wire_5, wire_6)
  end

  ### step 2

  def test_step_counter
    wire_1 = Wire.new("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    wire_2 = Wire.new("U62,R66,U55,R34,D71,R55,D58,R83")
    assert_equal 610, Solver_2.result(wire_1, wire_2)

    wire_3 = Wire.new("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
    wire_4 = Wire.new("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
    assert_equal 410, Solver_2.result(wire_3, wire_4)

  end
end

## Step 1 Solver

class Solver
  def self.result(wire_a, wire_b)
    intersections = wire_a.path & wire_b.path
    distances = intersections.map{ |i| manhatten_distance i }
    distances.sort[1] # get second lowest distance, as 0,0 is excluded
  end

  def self.manhatten_distance(coord)
    coord[0].abs + coord[1].abs
  end
end

class Solver_2 < Solver
  def self.result(wire_a, wire_b)
    intersections = wire_a.path & wire_b.path
    step_sums = intersections.map do |i|
      steps_1 = wire_a.path.find_index(i)
      steps_2 = wire_b.path.find_index(i)
      steps_1 + steps_2
    end
    step_sums.sort[1]
  end

end

class Wire
  attr_reader :path

  def initialize(input)
    @path = [[0,0]]
    commands = parse(input)
    execute(commands)
  end

  def parse(input)
    commands = input.split(",")
    commands.map do |c|
      direction = c.chars.first
      distance = c.chars[(1..-1)].join.to_i
      [direction, distance]
    end
  end

  def execute(commands)
    commands.each do |c|
      walk_path(c)
    end
  end

  def walk_path(command)
    command[1].times do 
      case command[0]
      when "U"
        move(0,1)
      when "D"
        move(0,-1)
      when "L"
        move(-1,0)
      when "R"
        move(1,0)
      end
    end
  end

  def move(x,y)
    current_position = @path.last
    @path << [current_position[0] + x, current_position[1] + y]
  end

  def dimension
    x = @path.map{ |c| c[0]}.max - @path.map{ |c| c[0]}.min
    y = @path.map{ |c| c[1]}.max - @path.map{ |c| c[1]}.min
    [x,y]
  end
end

class Canvas
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


wire_one = Wire.new(PUZZLE_INPUT[0])
wire_two = Wire.new(PUZZLE_INPUT[1])

# c = Canvas.new
# # it's too much for ruby, a 85mil length 2d array
# wire_one.path.each do |coord|
#   c.paint(coord[0], coord[1], "light_blue")
# end
# wire_two.path.each do |coord|
#   c.paint(coord[0], coord[1], "red")
# end
# c.print

part_1 = Solver.result(wire_one, wire_two)
puts "*" * 40
puts part_1
puts "*" * 40
part_2 = Solver_2.result(wire_one, wire_two)
puts "*" * 40
puts "Part 2"
puts part_2
puts "*" * 40
# part_1 = IntCode.new(PUZZLE_INPUT.split(","))
# part_1.compute
# puts part_1.result
# puts part_1.memory.inspect

# Part: 2
# determine what pair of inputs produces the output 19690720

puts ((Time.now.usec - now.usec)/1000).to_s + " ms"
