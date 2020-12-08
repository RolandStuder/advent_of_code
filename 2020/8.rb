require 'pry'
require "ostruct"
require 'set'
require 'minitest'
require 'minitest/autorun'


class Program
  attr_reader :accumulator, :instructions, :pointer, :visited
  def initialize(programm)
    @accumulator = 0
    @pointer = 0
    @raw_lines = programm.split("\n")
    @visited = Set[]
    @instructions = parse_instructions
  end

  def run
    loop do
      instruction = @instructions[@pointer]
      return self if @visited.include?(@pointer)
      @visited << @pointer
      send(instruction.operation, instruction.value)
    end
  end

  def parse_instructions
    @raw_lines.map do |line|
      operation, value = line.split
      OpenStruct.new({operation: operation.to_sym, value: value.to_i})
    end
  end

  def acc(value)
    @accumulator += value
    @pointer += 1
  end

  def jmp(value)
    @pointer += value
  end

  def nop(_value)
    @pointer += 1
  end
end


class ProgrammTest < Minitest::Test
  TEST_INPUT = %{nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
}

  def test_example
    p = Program.new(TEST_INPUT)
    assert_equal 5, p.run.accumulator
  end
end

program = Program.new(File.read("8.dat"))

puts "Solution 1"

puts program.run.accumulator

puts "Solution 2"


