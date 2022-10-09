# ruby -Ilib:test 2015/5.rb
require "minitest/autorun"
require_relative '../lib/grid'
require "./lib/parsing_helper"

pp Grid.with_size(2, 2)


class DecoractionDisplay
  attr_reader :grid

  def initialize
    @grid = Grid.with_size(1000, 1000, default_value: -> { Light.new })
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

class Day6Test < Minitest::Test
  def test_example_input

  end
end




display = DecoractionDisplay.new
display.perform
puts display.grid.slice(Coordinate.new(0,0), Coordinate.new(999,999)).count(&:on?)
