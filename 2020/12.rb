require 'pry'
require 'minitest'
require 'minitest/autorun'

class Ferry
  attr_reader :heading, :x, :y

  def initialize
    @heading = 90
    @x = 0
    @y = 0
  end

  def north(value)
    @y -= value
  end

  def south(value)
    @y += value
  end

  def west(value)
    @x -= value
  end

  def east(value)
    @x += value
  end

  def direction
    {
         0 => :north,
        90 => :east,
       180 => :south,
       270 => :west
    }[heading]
  end

  def left(degrees)
    @heading = (@heading - degrees + 360) % 360
  end

  def right(degrees)
    @heading = (@heading + degrees) % 360
  end

  def forward(value)
    send(direction, value)
  end
end

class WayPointFerry
  attr_reader :x, :y, :waypoint_x_delta, :waypoint_y_delta

  def initialize
    @x = 0
    @y = 0
    @waypoint_x_delta = 10
    @waypoint_y_delta = 1
  end

  def north(value)
    @waypoint_y_delta += value
  end

  def south(value)
    @waypoint_y_delta -= value
  end

  def west(value)
    @waypoint_x_delta -= value
  end

  def east(value)
    @waypoint_x_delta += value
  end


  # 90 degree turn to the right
  #   -            -
  # - 0 +x ==>  +y 0 -
  #  +y           +x

  def right(degrees)
    (degrees / 90).times do
      old_x_delta = @waypoint_x_delta
      old_y_delta = @waypoint_y_delta
      @waypoint_x_delta = old_y_delta
      @waypoint_y_delta = -old_x_delta
    end
  end

  def left(degrees)
    right(360 - degrees)
  end

  def forward(value)
    @x += value * @waypoint_x_delta
    @y += value * @waypoint_y_delta
  end
end

class CommandList
  attr_accessor :commands

  def self.new_from_string(input_string)
    list = self.new
    lines = input_string.split("\n")
    lines.each do |line|
      command = line.chars.first
      value = line[1..].to_i
      list.commands << OpenStruct.new({command: list.char_to_command(command), value: value})
    end
    list
  end

  def initialize
    @commands = []
  end

  def run(from: 0, to: commands.size-1, with: Ferry)
    ferry = with.new
    commands[from..to].each do |command|
      ferry.send(command.command, command.value)
    end
    ferry
  end

  def char_to_command(char)
    {
        N: :north,
        S: :south,
        W: :west,
        E: :east,
        R: :right,
        L: :left,
        F: :forward
    }[char.to_sym]
  end
end

describe Ferry do
  EXAMPLE_INPUT = <<~EOS
                        F10
                        N3
                        F7
                        R90
                        F11
                  EOS

  before do
  end

  it "initial direction is east" do
    assert_equal :east, Ferry.new.direction
  end

  it "converts commands" do
    list = CommandList.new_from_string(EXAMPLE_INPUT)
    assert_equal :forward, list.commands.first.command
    assert_equal 10, list.commands.first.value
  end

  it "runs example list" do
    list = CommandList.new_from_string(EXAMPLE_INPUT)
    ferry = list.run
    assert_equal 17, ferry.x
    assert_equal 8, ferry.y # I actually think this is reversed, but don't care enough to change right now
  end

  it "runs example list with WayPointFerry" do
    list = CommandList.new_from_string(EXAMPLE_INPUT)
    ferry = list.run(with: WayPointFerry)
    assert_equal 214, ferry.x
    assert_equal -72, ferry.y # I actually think this is reversed, but don't care enough to change right now
  end

  it "runs example list with WayPointFerry" do
    list = CommandList.new_from_string(EXAMPLE_INPUT)
    ferry = list.run(from: 0, to: 0, with: WayPointFerry)
    assert_equal 100, ferry.x
    assert_equal 10, ferry.y

    ferry = list.run(from: 0, to: 1, with: WayPointFerry)
    assert_equal 10, ferry.waypoint_x_delta
    assert_equal 4, ferry.waypoint_y_delta

    ferry = list.run(from: 0, to: 2, with: WayPointFerry)
    assert_equal 170, ferry.x
    assert_equal 38, ferry.y
    puts "Solution 1"
  end
end

list = CommandList.new_from_string(File.read("12.dat"))
ferry = list.run
puts ferry.x.abs + ferry.y.abs

puts "Solution 2"
list = CommandList.new_from_string(File.read("12.dat"), )
ferry = list.run(with: WayPointFerry)
puts ferry.x.abs + ferry.y.abs
