require "./lib/parsing_helper"
require "minitest/autorun"


class CorruptedMemoryParser
  def initialize(string, allowed_operations: [Multiplication])
    @raw = string
    @allowed_operations = allowed_operations
  end

  def execute
    env = OperationEnv.new(value: 0, enabled: true)
    @raw.scan(/#{@allowed_operations.map(&:regexp).join('|')}/).map do |match|
      operation = @allowed_operations.find {|operation| opertion.regexp.match(match) }.new(match)
      operation.execute(env)
    end
    env.value
  end
end

class Operation
  def initialize(string)
    @string = string
  end
end

class Multiplication < Operation
  def self.regexp = /mul\(\d+,\d+\)/

  def execute(env)
    if env.enabled?
      env.value += @string.scan(/\d+/).map(&:to_i).reduce(&:*)
    end
  end
end

class Do < Operation
  def self.regexp = /do\(\)/

  def execute(env)
    env.enabled = true
  end
end

class Dont < Operation
  def self.regexp = /don\'t\(\)/
  def execute(env)
    env.enabled = false
  end
end

class CorruptedMemoryParserTest < Minitest::Test
  def test_extract_multiplications
    example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    assert_equal 161, CorruptedMemoryParser.new(example).execute
  end

  def test_extract_instructions
    example = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    assert_equal 48, CorruptedMemoryParser.new(example, allowed_operations: [Multiplication, Do, Dont]).execute
  end
end


puts CorruptedMemoryParser.new(ParsingHelper.load(2024, 3).lines.join).execute
puts CorruptedMemoryParser.new(ParsingHelper.load(2024, 3).lines.join, allowed_operations: [Multiplication, Do, Dont]).execute
