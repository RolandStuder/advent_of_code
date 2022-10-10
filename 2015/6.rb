# ruby -Ilib:test 2015/5.rb
require "minitest/autorun"
require_relative '../lib/grid'
require "./lib/parsing_helper"

class DecoractionDisplay
  attr_reader :grid

  def initialize(light_class = Light)
    @grid = Grid.with_size(1000, 1000, default_value: -> { light_class.new })
  end

  def perform
    lines = ParsingHelper.load(2015,6).lines
    lines.each do |line|
      match = line.match(/(.*)\s(\d*),(\d*)\sthrough\s(\d*),(\d*)/)
      verb = match[1].gsub(" ", "_").to_sym
      from = Coordinate.new(match[2], match[3])
      to = Coordinate.new(match[4], match[5])

      grid.slice(from, to).each(&verb)
    end
  end
end

class Light
  attr_reader :state

  def initialize(state = :off)
    @state = state
  end

  def toggle
    if on?
      turn_off
    else
      turn_on
    end
  end

  def turn_on
    @state = :on
  end

  def turn_off
    @state = :off
  end

  def on?
    @state == :on
  end

  def off?
    @state == :off
  end
end

class DimmableLight
  attr_reader :brightness

  def initialize
    @brightness = 0
  end

  def toggle
    @brightness += 2
  end

  def turn_on
    @brightness += 1
  end

  def turn_off
    @brightness -= 1 unless @brightness.zero?
  end
end

class Day6Test < Minitest::Test
  def test_part_1
    display = DecoractionDisplay.new
    display.perform
    assert_equal 569999, display.grid.slice(Coordinate.new(0,0), Coordinate.new(999,999)).count(&:on?)
  end
end

puts "Warning: Be patient, my solution is quite slow"
# Part 1

display = DecoractionDisplay.new
display.perform
puts display.grid.slice(Coordinate.new(0,0), Coordinate.new(999,999)).count(&:on?)

# Part 2

display = DecoractionDisplay.new(DimmableLight)
display.perform
puts display.grid.slice(Coordinate.new(0,0), Coordinate.new(999,999)).sum(&:brightness)
