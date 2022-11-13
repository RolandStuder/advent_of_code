require "minitest/autorun"
require "./lib/parsing_helper"

class Reindeer
  attr_reader :name, :speed, :flying_time, :flying_time_left, :resting_time, :resting_time_left, :distance_travelled, :time_passed, :state, :score

  def initialize(name:, speed:, flying_time:, resting_time:, distance_travelled: 0, time_passed: 0)
    @name = name
    @speed = speed.to_i
    @flying_time = flying_time.to_i
    @resting_time = resting_time.to_i
    @distance_travelled = distance_travelled
    @time_passed = 0
    @state = :flying
    @flying_time_left = @flying_time
    @resting_time_left = @resting_time
    @score = 0
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

  def add_point
    @score += 1
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


reindeers = ParsingHelper.load(2015, 14).lines.map do |line|
  matches = line.match(/(.*) can fly (.*) km\/s for (.*) seconds, but then must rest for (.*) seconds/)
  Reindeer.new(name: matches[1], speed: matches[2], flying_time: matches[3], resting_time: matches[4])
end


puts "PART: 1"
puts reindeers.map{ |reindeer| reindeer.travel(2503).distance_travelled }.max


puts "PART: 2"

reindeers = ParsingHelper.load(2015, 14).lines.map do |line|
  matches = line.match(/(.*) can fly (.*) km\/s for (.*) seconds, but then must rest for (.*) seconds/)
  Reindeer.new(name: matches[1], speed: matches[2], flying_time: matches[3], resting_time: matches[4])
end

2503.times do
  reindeers.map{ |reindeer| reindeer.travel(1).distance_travelled }
  current_lead = reindeers.map(&:distance_travelled).max
  reindeers.select { |reindeer| current_lead == reindeer.distance_travelled }.each(&:add_point)
end

puts reindeers.map(&:score).max

