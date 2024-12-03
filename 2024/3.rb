require "./lib/parsing_helper"
require "minitest/autorun"


class CorruptedMemoryParser
  def initialize(string)
    @raw = string
  end

  def integer_pairs
    @raw.scan(/mul\((\d+),(\d+)\)/).map { |pair| pair.map(&:to_i)}
  end

  def sum_of_multiplications
    integer_pairs.sum { _1 * _2 }
  end
end

class CorruptedMemoryParserTest < Minitest::Test
  def example
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
  end

  def test_extract_multiplications
    assert_equal 161, CorruptedMemoryParser.new(example).sum_of_multiplications
  end
end


puts CorruptedMemoryParser.new(ParsingHelper.load(2024, 3).lines.join).sum_of_multiplications
