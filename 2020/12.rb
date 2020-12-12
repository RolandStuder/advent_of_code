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

  def run
    ferry = Ferry.new
    commands.each do |command|
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
end

puts "Solution 1"
list = CommandList.new_from_string(File.read("12.dat"))
ferry = list.run
puts ferry.x.abs + ferry.y.abs
