# ruby -Ilib:test 2015/1.rb
require "minitest/autorun"
require "./lib/parsing_helper"


class Package
  attr_accessor :w, :l, :h
  def initialize(width, length, height)
    @w = width
    @l = length
    @h = height
  end

  def surface
    areas.map { |a| a*2 }.sum
  end

  def areas
    [(l*w),(w*h),(h*l)]
  end

  def paper_needed
    surface + areas.min
  end

  def ribbon_needed
    ([w,l,h].sort.first(2).sum * 2) + w*h*l
  end
end

class Day2Test < Minitest::Test
  def test_example_input
    assert_equal 58, Package.new(2,3,4).paper_needed
    assert_equal 34, Package.new(2,3,4).ribbon_needed
  end
end

parsed = ParsingHelper.load(2015, 2).lines.map { |l| l.split("x").map(&:to_i) }
pp parsed.map { |line| Package.new(*line).paper_needed}.sum
pp parsed.map { |line| Package.new(*line).ribbon_needed}.sum
