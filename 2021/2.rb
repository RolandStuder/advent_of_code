# ruby -Ilib:test 2021/2.rb
require "minitest/autorun"

class Submarine
  attr_accessor :depth, :horizontal_position

  def initialize
    self.horizontal_position = 0
    self.depth = 0
  end

  def forward(units)
    self.horizontal_position += units
  end

  def down(units)
    self.depth += units
  end

  def up(units)
    down(-units)
  end
end

class SubmarineWithAim < Submarine
  attr_accessor :aim

  def initialize
    self.aim = 0
    super
  end

  def down(units)
    self.aim += units
  end

  def forward(units)
    self.depth += units * aim
    super
  end
end


class TestMeme < Minitest::Test
  def test_example_input
    submarine = Submarine.new
    data = %{forward 5
             down 5
             forward 8
             up 3
             down 8
             forward 2}
    data.split("\n").each do |instruction|
      command, units = instruction.split
      submarine.send command, units.to_i
    end
    assert_equal 10, submarine.depth
    assert_equal 15, submarine.horizontal_position
  end

  def test_example_input
    submarine = SubmarineWithAim.new
    data = %{forward 5
             down 5
             forward 8
             up 3
             down 8
             forward 2}
    data.split("\n").each do |instruction|
      command, units = instruction.split
      submarine.send command, units.to_i
    end
    assert_equal 60, submarine.depth
    assert_equal 15, submarine.horizontal_position
  end
end


# PART 1
#
submarine = Submarine.new

File.readlines('2021/2.data').each do |instruction|
  command, units = instruction.split
  submarine.send command, units.to_i
end

pp submarine.depth * submarine .horizontal_position

# PART 2
#
submarine = SubmarineWithAim.new

File.readlines('2021/2.data').each do |instruction|
  command, units = instruction.split
  submarine.send command, units.to_i
end

pp submarine.depth * submarine .horizontal_position