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

    assert_equal 8, JoltAdapter.valid_arrangements.count
  end
end

JoltAdapter.clear
JoltAdapter.from_string(File.read("10.dat"))
puts "Solution 1"
diff = JoltAdapter.difference_distribution
puts diff[3] * diff[1]

puts "Solution 2"
JoltAdapter.valid_arrangements.count
