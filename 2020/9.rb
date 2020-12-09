require 'pry'
require 'minitest'
require 'minitest/autorun'
require_relative 'lib/summands'


class XMAS
  attr_accessor :preamble_length
  attr_reader :entries

  def initialize(numbers, preamble_length = 5)
    @entries = numbers
    @preamble_length = preamble_length
  end

  def self.from_string(numbers_string)
    self.new(numbers_string.split("\n").map(&:to_i))
  end

  def valid?(number)
    index = @entries.index(number)
    return true if index < @preamble_length

    preamble_entries = @entries[(index - preamble_length)..(index - 1)]
    Summands.new(preamble_entries).sum_possible?(number)
  end

  def invalid?(number)
    !valid?(number)
  end

  def find_first_invalid
    @entries.find do |n| invalid?(n)  end
  end

  def line(number)
    @entries[number]
  end

  def contiguous_set_for(number)
    index = 0
    length = 2

    loop do
      current = @entries[index...(index+length)]
      return current if current.sum == number
      if current.sum > number
        index += 1
        length = 2
      else
        length += 1
      end
    end
  end
end


class XMASTest < Minitest::Test
  TEST_INPUT = %{35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
}

  def test_example
    xmas = XMAS.from_string(TEST_INPUT)
    assert xmas.valid? (xmas.entries.first)
    assert xmas.valid? (xmas.entries[6])
    assert_equal 127,xmas.find_first_invalid
    assert_equal 15, xmas.contiguous_set_for(127).min
    assert_equal 47, xmas.contiguous_set_for(127).max
  end
end

puts "Solution 1"
xmas = XMAS.from_string(File.read("9.dat"))
xmas.preamble_length = 25
puts xmas.find_first_invalid

puts "Solution 2"
set = xmas.contiguous_set_for(xmas.find_first_invalid)
puts set.min + set.max
