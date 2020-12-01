require 'minitest'
require 'minitest/autorun'

class RobotTest < Minitest::Test
  def setup
    programm = File.open("11.dat").readlines.join.split(",")
    @robot = Robot.new(programm)
  end

  def test_read_first_square
    robot = Robot.new([99])
    assert_equal "black", robot.tile_color
  end
end
