require 'pry'
require 'minitest'
require 'minitest/autorun'
require_relative 'lib/summands'


class JoltAdapter
  attr_reader :joltage
  @list = []

  class << self
    def all
      @list
    end

    def clear
      @list = []
    end

    def joltages
      @list.map(&:joltage)
    end

    def create(joltage:)
      @list << new(joltage: joltage)
    end

    def from_string(input_string, with_ultimate_adapator: true)
      input_string.split("\n").map(&:to_i).each do |number|
        create(joltage: number)
      end
      create(joltage: 0) # start at 0s
      create(joltage: joltages.max + 3) if with_ultimate_adapator
    end

    def difference_distribution(joltages: all.map(&:joltage).sort)
      differences = joltages.each_with_index.map { |joltage, index| joltages[index+1] - joltage if joltages[index+1] }
      (differences - [nil]).tally
    end

    def possible_arrangements
      joltages = self.joltages.sort
      max_joltage = joltages.max
      minimum_adapters = max_joltage / 3 + 2
      min_joltage = joltages.min
      possible = []
      1.upto(joltages.size) do |length|
        if length > minimum_adapters
          possible += joltages[1..-2].combination(length).to_a.map do |arr|
            [min_joltage, arr, max_joltage].flatten
          end
        end
      end
      possible
    end

    def valid_arrangements
      possible_arrangements.select do |arr|
        arr.each_with_index.none? do |joltage, index|
          next if !arr[index+1]
          (arr[index+1] - joltage) > 3
        end
      end
    end
  end

  def initialize(joltage:)
    @joltage = joltage
  end
end

class JoltTree
  def self.from_string(input_string)
    joltages = input_string.split("\n").map(&:to_i)
    joltages += [0, (joltages.max + 3)]
    joltages.sort!
    @max_value = joltages.last
    @joltages = joltages.map do |value|
      possible_predecessors = joltages.select {|j| j.between?(value-3, value-1) }
      Joltage.new(value, possible_predecessors)
    end
  end

  def self.clear
    @max_value = nil
    @joltages = []
  end

  def self.find_by_value(value)
    @joltages.find{ |joltage| joltage.value == value }
  end

  def self.count_ways
    @joltages.each do |joltage|
      sum = joltage.possible_predecessors.map(&:ways_to_get_there).sum
      joltage.ways_to_get_there = sum > 0 ? sum : 1
      puts joltage.ways_to_get_there
    end
    @joltages.last.ways_to_get_there
  end

  class Joltage
    attr_reader :value, :possible_predecessors
    attr_accessor :ways_to_get_there
    def initialize(value, possible_predecessors)
      @value = value
      @possible_predecessors = possible_predecessors
      @ways_to_get_there = 1
    end

    def possible_predecessors
      return @_possible_predecessors if @_possible_predecessors
      @_possible_predecessors = @possible_predecessors.map { |j| JoltTree.find_by_value(j) }
    end
  end
end


class JoltAdapterTests < Minitest::Test
  TEST_INPUT = %{16
10
15
5
1
11
7
19
6
12
4
}

  def test_example
    JoltAdapter.clear
    JoltAdapter.from_string(TEST_INPUT)
    dist = JoltAdapter.difference_distribution
    assert_equal 5, dist[3]
    assert_equal 7, dist[1]

    JoltTree.clear
    JoltTree.from_string(TEST_INPUT)
    assert_equal 8, JoltTree.count_ways
  end
end

JoltAdapter.clear
JoltAdapter.from_string(File.read("10.dat"))
puts "Solution 1"
diff = JoltAdapter.difference_distribution
puts diff[3] * diff[1]

puts "Solution 2"
JoltTree.clear
JoltTree.from_string(File.read("10.dat"))
puts JoltTree.count_ways
