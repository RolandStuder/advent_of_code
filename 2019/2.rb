require 'pry'
require 'minitest'
require "minitest/autorun"

TEST_INPUT = "1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.
".freeze

PUZZLE_INPUT = "1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,5,19,23,2,9,23,27,1,27,5,31,2,31,13,35,1,35,9,39,1,39,10,43,2,43,9,47,1,47,5,51,2,13,51,55,1,9,55,59,1,5,59,63,2,6,63,67,1,5,67,71,1,6,71,75,2,9,75,79,1,79,13,83,1,83,13,87,1,87,5,91,1,6,91,95,2,95,13,99,2,13,99,103,1,5,103,107,1,107,10,111,1,111,13,115,1,10,115,119,1,9,119,123,2,6,123,127,1,5,127,131,2,6,131,135,1,135,2,139,1,139,9,0,99,2,14,0,0".freeze


## STEP 1 Tests

class SolverTests < Minitest::Test
  def test_solver
    lines = TEST_INPUT.split("\n")
    lines.each do |line|
      # separate start and end state
      matches = line.match(/((?:\d+,?)+) becomes ((?:\d+,?)+)/)
      input = matches[1].split(",")
      output = matches[2].split(",")

      solver = IntCode.new(input, fix: false)
      solver.compute

      assert_equal output.first.to_i, solver.result
    end
  end
end

## Step 1 Solver

class IntCode
  attr_reader :memory
  # array of numbers
  def initialize(input, fix: true)
    @memory = input.map(&:to_i)
    @computed = false
    fix_programm if fix
    # instruction_pointer
    @address = 0
  end

  def compute
    return terminate if @memory[@address] == 99

    # opcode
    case @memory[@address]
    when 1
      @memory[target] = argument_1 + argument_2
    when 2
      @memory[target] = argument_1 * argument_2
    end
    
    #After an instruction finishes, the instruction pointer
    # increases by the number of values in the instruction
    @address += 4
    compute
  end

  def memory
    compute unless @computed
    @memory
  end

  def result
    compute unless @computed
    @memory[0]
  end

  def noun= value
    @memory[1] = value
  end

  def verb= value
    @memory[2] = value
  end

  private

  def terminate
    @computed = true
    @memory[0]
  end

  # parameters
  def argument_1
    argument_position = @memory[@address + 1]
    @memory[argument_position]
  end

  def argument_2
    argument_position = @memory[@address + 2]
    @memory[argument_position]
  end

  def target
    @memory[@address + 3]
  end

  def fix_programm
    noun = 12
    verb = 2
  end
end

part_1 = IntCode.new(PUZZLE_INPUT.split(","))
part_1.compute
puts part_1.result
puts part_1.memory.inspect

# Part: 2
# determine what pair of inputs produces the output 19690720

input = PUZZLE_INPUT.split(",")

(0..99).each do |noun| 
  (0..99).each do |verb|
    programm = IntCode.new(input)
    programm.noun = noun
    programm.verb = verb
    programm.result
    if programm.result == 19690720
      puts "*" * 40
      puts programm.result
      puts "achievied by"
      puts "noun: #{noun}"
      puts "verb: #{verb}"
      puts "answer:: #{100 * noun + verb}"
      puts "*" * 40
    end
  end
end