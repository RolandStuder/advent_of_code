require "minitest/autorun"
require "./lib/parsing_helper"

class Ingredient
  attr_reader :name, :capacity, :durability, :flavor, :texture, :calories

  def initialize(name: "", capacity:, durability:, flavor:, texture:, calories:)
    @name = name
    @capacity = capacity
    @durability = durability
    @flavor = flavor
    @texture = texture
    @calories = calories
  end
end

class Cookie
  attr_accessor :ingredients
  def initialize
    @ingredients = {}
  end

  def add(ingredient, teaspoons)
    @ingredients[ingredient] = teaspoons
  end

  def total_score
    raise "Need exactly 100 teaspons" unless @ingredients.values.sum == 100

    scores.values.inject(1, &:*)
  end

  def scores
    [:capacity, :durability, :flavor, :texture].map do |property|
      sum = @ingredients.sum { |ingredient, teaspoons| ingredient.public_send(property) * teaspoons}
      [property, (sum.positive? ? sum : 0)]
    end.to_h
  end

  def calories
    @ingredients.sum { |ingredient, teaspoons| ingredient.calories * teaspoons}
  end
end

class Day15Test < Minitest::Test
  def test_part_example
    butterscotch = Ingredient.new(name: "Butterscotch", capacity: -1, durability: -2, flavor: 6, texture: 3, calories: 8)
    cinnamon = Ingredient.new(name: "Cinnamon", capacity: 2, durability: 3, flavor: -2, texture: -1, calories: 3)

    cookie = Cookie.new
    cookie.add(butterscotch, 44)
    cookie.add(cinnamon, 56)
    assert_equal 68, cookie.scores[:capacity]
    assert_equal 62842880, cookie.total_score
  end
end


# Frosting: capacity 4, durability -2, flavor 0, texture 0, calories 5
frosting = Ingredient.new(name: "Frosting", capacity: 4, durability: -2, flavor: 0, texture: 0, calories: 5)
# Candy: capacity 0, durability 5, flavor -1, texture 0, calories 8
candy = Ingredient.new(name: "Candy", capacity: 0, durability: 5, flavor: -1, texture: 0, calories: 8)
# Butterscotch: capacity -1, durability 0, flavor 5, texture 0, calories 6
butterscotch = Ingredient.new(name: "Butterscotch", capacity: -1, durability: 0, flavor: 5, texture: 0, calories: 6)
# Sugar: capacity 0, durability 0, flavor -2, texture 2, calories 1
sugar = Ingredient.new(name: "Sugar", capacity: 0, durability: 0, flavor: -2, texture: 2, calories: 1)

max = 0
(0..100).each do |a|
  (0..(100-a)).each do |b|
    (0..(100-a-b)).each do |c|
      cookie = Cookie.new
      cookie.add(frosting, a)
      cookie.add(candy, b)
      cookie.add(butterscotch, c)
      cookie.add(sugar, (100-a-b-c))
      total_score = cookie.total_score
      if total_score > max
        max = total_score
      end
    end
  end
end

puts "Part: 1"
puts max

max = 0
(0..100).each do |a|
  (0..(100-a)).each do |b|
    (0..(100-a-b)).each do |c|
      cookie = Cookie.new
      cookie.add(frosting, a)
      cookie.add(candy, b)
      cookie.add(butterscotch, c)
      cookie.add(sugar, (100-a-b-c))
      total_score = cookie.total_score
      if total_score > max && cookie.calories == 500
        max = total_score
      end
    end
  end
end

puts "Part: 2"
puts max
