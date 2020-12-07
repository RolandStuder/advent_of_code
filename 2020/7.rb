require 'pry'
require 'minitest'
require 'minitest/autorun'


class Bag
  @list = []
  attr_accessor :should_contain, :style, :color

  class << self
    def find(style, color)
      @list.find{ |bag| (bag.style == style && bag.color == color)}
    end

    def all
      @list
    end

    def clear
      @list = []
    end

    def all_as_string
      @list.map { |bag| "#{bag.style} #{bag.color}" }
    end

    def find_or_create(style, color)
      return self.find(style, color) if self.find(style, color)
      bag = self.new(style, color)
      @list << bag
      puts "created #{style} #{color}"
      bag
    end

    def from_string(rule_string)
      outside, inside = rule_string.split("bags contain")

      style, color = outside.split
      bag = Bag.find_or_create(style, color)

      inside_definitions = inside.split(",")
      inside_definitions.map do |combo|
        amount, style, color = combo.split
        amount.to_i.times do
          bag.should_contain << Bag.find_or_create(style, color)
        end
      end
      bag
    end
  end

  def initialize(style, color)
    @style = style
    @color = color
    @should_contain = []
  end

  def should_contain(deep: false)
    return @should_contain unless deep

    @should_contain + @should_contain.map { |bag| bag.should_contain(deep: true) }.flatten
  end

  def will_contain?(bag)
    return true if @should_contain.uniq.include?(bag)

    @should_contain.uniq.any? { |b| b.will_contain?(bag) }
  end

  def to_s
    "#@style #@color"
  end
end


class DeclarationsTest < Minitest::Test
  TEST_INPUT = %{light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
}
  # before do
  #   bag_rules = TEST_INPUT.split(/\n/)
  #   bag_rules.each do |rule|
  #     Bag.from_string( rule )
  #   end
  # end

  def test_example
  Bag.clear
  bag_rules = TEST_INPUT.split(/\n/)
  bag_rules.each do |rule|
    Bag.from_string( rule )
  end

  first = Bag.all.first
    assert_equal first.color, "red"
    assert_equal first.style, "light"
    assert_equal 1, first.should_contain.count { |bag| bag.color == "white" && bag.style == "bright"}
    assert_equal 2, first.should_contain.count { |bag| bag.color == "yellow" && bag.style == "muted"}
  end

  def test_example_recursive
    Bag.clear
    bag_rules = TEST_INPUT.split(/\n/)
    bag_rules.each do |rule|
      Bag.from_string( rule )
    end

    count = Bag.all.count do |bag|
      bag.should_contain(deep: true).include? Bag.find("shiny", "gold")
    end
    assert_equal 4, count

    count = Bag.all.count do |bag|
      bag.will_contain?(Bag.find("shiny", "gold"))
    end
    assert_equal 4, count
  end
end

Bag.clear

bag_rules = File.readlines("7.dat")
bag_rules.each do |rule|
  Bag.from_string( rule )
end


puts "Solution 1"

count = Bag.all.count do |bag|
  bag.will_contain?(Bag.find("shiny", "gold"))
end

puts count


puts "Solution 2"


