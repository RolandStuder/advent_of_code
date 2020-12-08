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
      raise InfiniteLoopException if @visited.include?(@pointer)
      puts @pointer, @instructions.size
      return self if @pointer == @instructions.size
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

  def overwrite(line, instruction)
    @instructions[line] = instruction
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

  class InfiniteLoopException < StandardError
    def initialize(msg="Infinite Loop reached", exception_type="custom")
      @exception_type = exception_type
      super(msg)
    end
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
    assert_raises Program::InfiniteLoopException do
      p.run
    end
    assert_equal 5, p.accumulator
  end
end

program = Program.new(File.read("8.dat"))

puts "Solution 1"

begin
  program.run
rescue
  puts program.accumulator
end

puts "Solution 2"

# candidate_instructions = program.


