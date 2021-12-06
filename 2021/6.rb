# ruby -Ilib:test 2021/6.rb
require "minitest/autorun"
require_relative "lib/parsing_helper"

class AnglerFishSwarm
  def initialize(timers)
    @fishes = timers.map do |timer|
      Fish.new(timer)
    end
  end

  def tick
    @fishes = @fishes.map(&:tick).flatten
    self
  end

  def to_numbers
    @fishes.map(&:to_number)
  end
end

class Fish
  attr_reader :timer
  def initialize(timer)
    @timer = timer
  end

  def tick
    case timer
    when 0
      @timer = 6
      return [self, Fish.new(8)]
    else
      @timer -= 1
      return [self]
    end
  end

  def to_number
    timer
  end
end

# creative idea, terrible approach
class AnglerFishSwarmPatterns
  def initialize
    @patterns = {}
  end

  def for(initial, days)
    return  @patterns["#{initial}-#{days}"] if @patterns["#{initial}-#{days}"]

    if (days % 2 == 0)
      numbers = initial
      2.times do
        numbers = self.for(numbers, (days / 2))
      end
      @patterns["#{initial}-#{days}"] = numbers

    else
      swarm = AnglerFishSwarm.new(initial)
      days.times do
        swarm.tick
      end
      @patterns["#{initial}-#{days}"] = swarm.to_numbers
    end
    pp "pattern found "
    @patterns["#{initial}-#{days}"]
  end
end

# KISS
class AnglerFishSwarmMass
  attr_reader :tally
  def initialize(numbers)
    @tally = Hash.new(0)
    @tally.merge!(numbers.tally)
  end

  def tick(times=1)
    times.times do
      @tally = {
        0 => @tally[1],
        1 => @tally[2],
        2 => @tally[3],
        3 => @tally[4],
        4 => @tally[5],
        5 => @tally[6],
        6 => @tally[7] + @tally[0],
        7 => @tally[8],
        8 => @tally[0]
      }
    end
  end

  def count
    @tally.values.sum
  end
end




class Day6Test < Minitest::Test
  def test_example_input
    example_input = %{3,4,3,1,2}

    numbers = example_input.split(",").map(&:to_i)
    swarm = AnglerFishSwarm.new(numbers)
    assert_equal [3,4,3,1,2], swarm.to_numbers
    assert_equal [2,3,2,0,1], swarm.tick.to_numbers
    assert_equal [1,2,1,6,0,8].sort, swarm.tick.to_numbers.sort
  end
end

# PART 1

initial = ParsingHelper.load(6).lines.first.split(",").map(&:to_i)
swarm = AnglerFishSwarm.new(initial)
80.times do
  swarm.tick
end

pp "Part: 1"
pp swarm.to_numbers.count
pp "----------"

swarm = AnglerFishSwarmMass.new(initial)
80.times do
  swarm.tick
end

pp "Part: 1"
pp swarm.count
pp "----------"


swarm = AnglerFishSwarmMass.new(initial)
swarm.tick(256)

pp "Part: 2"
pp swarm.count
pp "----------"
