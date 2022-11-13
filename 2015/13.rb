require "minitest/autorun"
require "./lib/parsing_helper"

class Congregation
  attr_reader :people

  def initialize
    @people = {}
  end

  def add_from_line(string)
    match = string.match(/(.*) would (.*) (.*) happiness units by sitting next to (.*)\./)
    name = match[1]
    direction = match[2] == "gain" ? 1 : -1
    delta = match[3].to_i
    other_name = match[4]
    person = add_person(name)
    person.add_modifier(other_name, delta * direction)
  end

  def add_person(name)
    people[name] ||= Person.new(name)
  end

  def max_happiness_delta
    people.values.permutation.map {  |people|
      people.map.with_index { |person, index|
        next_index = (index+1 == people.size) ? 0 : index+1
        previous_index = index - 1
        next_person = people[next_index]
        previous_person = people[previous_index]

        person.modifiers[next_person.name] + person.modifiers[previous_person.name]
      }.sum
    }.max
  end
end

class Person
  attr :name, :modifiers
  def initialize(name)
    @name = name
    @modifiers = {}
  end

  def add_modifier(other_name, change)
    @modifiers[other_name] = change
  end
end

EXAMPLE_DATA = %{Alice would gain 54 happiness units by sitting next to Bob.
Alice would lose 79 happiness units by sitting next to Carol.
Alice would lose 2 happiness units by sitting next to David.
Bob would gain 83 happiness units by sitting next to Alice.
Bob would lose 7 happiness units by sitting next to Carol.
Bob would lose 63 happiness units by sitting next to David.
Carol would lose 62 happiness units by sitting next to Alice.
Carol would gain 60 happiness units by sitting next to Bob.
Carol would gain 55 happiness units by sitting next to David.
David would gain 46 happiness units by sitting next to Alice.
David would lose 7 happiness units by sitting next to Bob.
David would gain 41 happiness units by sitting next to Carol.}

class Day13Test < Minitest::Test
  def test_part_example
    congregation = Congregation.new
    EXAMPLE_DATA.split("\n").each do |line|
      congregation.add_from_line(line)
    end

    assert_equal 330, congregation.max_happiness_delta
  end
end


puts "PART: 1"

congregation = Congregation.new
ParsingHelper.load(2015, 13).lines.each do |line|
  congregation.add_from_line(line)
end
puts congregation.max_happiness_delta

puts "PART: 2"


