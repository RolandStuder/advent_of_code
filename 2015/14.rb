require "minitest/autorun"
require "./lib/parsing_helper"

class Reindeer
  attr_reader :name, :speed, :flying_time, :flying_time_left, :resting_time, :resting_time_left, :distance_travelled, :time_passed, :state

  def initialize(name:, speed:, flying_time:, resting_time:, distance_travelled: 0, time_passed: 0)
    @name = name
    @speed = speed
    @flying_time = flying_time
    @resting_time = resting_time
    @distance_travelled = distance_travelled
    @time_passed = 0
    @state = :flying
    @flying_time_left = flying_time
    @resting_time_left = resting_time
  end

  def travel(seconds)
    seconds.times do
      if flying?
        fly
      else
        rest
      end
    end
    self
  end

  def flying?
    @state == :flying
  end

  def rest
    @state = :resting
    @resting_time_left -= 1
    if resting_time_left.zero?
      @state = :flying
      @flying_time_left = flying_time
    end
    self
  end

  def fly
    @state = :flying
    @flying_time_left -= 1
    @distance_travelled += speed
    if flying_time_left.zero?
      @state = :resting
      @resting_time_left = resting_time
    end
    self
  end
end

class Day14Test < Minitest::Test
  def test_part_example
    comet = Reindeer.new(name: "Comet", speed: 14, flying_time: 10, resting_time: 127)
    dancer = Reindeer.new(name: "Dancer", speed: 16, flying_time: 11, resting_time: 162)

    assert_equal 1120, comet.travel(1000).distance_travelled
    assert_equal 1056, dancer.travel(1000).distance_travelled
  end
end


puts "PART: 1"

puts "PART: 2"

