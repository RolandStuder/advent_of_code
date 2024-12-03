require "./lib/parsing_helper"
require "minitest/autorun"


class CorruptedMemoryParser
  MULTIPLICATION = /mul\(\d+,\d+\)/
  DO = /do\(\)/
  DONT = /don\'t\(\)/

  def initialize(string)
    @raw = string
  end

  def execute
    value = 0
    enabled = true
    instructions.each do |matched_string|
      case matched_string
      when MULTIPLICATION
        value += matched_string.scan(/\d+/).map(&:to_i).reduce(&:*) if enabled
      when DO
        enabled = true
      when DONT
        enabled = false
      end
    end
    value
  end

  private

  def instructions
    @raw.scan(/#{MULTIPLICATION}|#{DO}|#{DONT}/)
  end
end

class CorruptedMemoryParserTest < Minitest::Test
  def test_extract_multiplications
    example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    assert_equal 161, CorruptedMemoryParser.new(example).execute
  end

  def test_extract_instructions
    example = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    assert_equal 48, CorruptedMemoryParser.new(example).execute
  end
end


puts CorruptedMemoryParser.new(ParsingHelper.load(2024, 3).lines.join).execute
