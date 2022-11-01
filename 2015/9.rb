# ruby -Ilib:test 2015/5.rb
require "minitest/autorun"
require_relative '../lib/grid'
require "./lib/parsing_helper"

class Location
  attr_reader :name, :distances

  def self.find(name)
    @locations ||= {}
    @locations[name] ||= new(name)
  end

  def self.from_string(string)
    # London to Dublin = 464
    match = string.match(/(\w+) to (\w+) = (\d+)/)
    from = match[1]
    to = match[2]
    distance = match[3].to_i
    location = find(from)
    location.connect(to, distance)
    # also do reverse
    location = find(to)
    location.connect(from, distance)
  end

  def self.shortest_with_all_locations
    paths = @locations.keys.permutation.to_a
    minimum_distance = 1_000_000_000
    paths.each do |locations|
      current_distance = 0
      locations.each.with_index do |name, index|
        break if locations[index + 1].nil?
        current_distance += find(name).distance_to(locations[index + 1])
      end
      if current_distance < minimum_distance
        minimum_distance = current_distance
      end
    end
    minimum_distance
  end

  def self.longest_distance_with_all_locations
    paths = @locations.keys.permutation.to_a
    maximum_distance = 0
    paths.each do |locations|
      current_distance = 0
      locations.each.with_index do |name, index|
        break if locations[index + 1].nil?
        current_distance += find(name).distance_to(locations[index + 1])
      end
      if current_distance > maximum_distance
        maximum_distance = current_distance
      end

    end
    maximum_distance
  end

  def self.reset
    @locations = {}
  end

  def initialize(name)
    @name = name
    @distances = {}
  end

  def connect(other_name, distance)
    @distances[other_name] = distance
  end

  def distance_to(other_name)
    @distances[other_name]
  end
end



class Day8Test < Minitest::Test
  def test_part_example
    Location.reset

    Location.from_string("London to Dublin = 464")
    Location.from_string("London to Belfast = 518")
    Location.from_string("Dublin to Belfast = 141")

    assert_equal 605, Location.shortest_with_all_locations
  end
end


Location.reset

ParsingHelper.load(2015, 9).lines.each do |line|
  Location.from_string(line)
end

puts "Part: 1"
puts Location.shortest_with_all_locations

puts "Part: 2"
puts Location.longest_distance_with_all_locations
