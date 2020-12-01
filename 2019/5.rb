require 'pry'
require 'minitest'
require "minitest/autorun"


TEST_INPUT = "1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.
".freeze


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

  def test_output_programm
    programm = [3,0,4,0,99]
    input = 5
    runner = IntCode.new(programm, 5, fix: false)
    runner.compute
    assert_equal input, runner.output.first
  end

  def test_output_programm
    programm = [1002,4,3,4,33]
    runner = IntCode.new(programm, nil, fix: false)
    runner.compute
  end

  def test_with_negatives
    programm = [1101,100,-1,4,0]
    runner = IntCode.new(programm, nil, fix: false)
    runner.compute
  end
end


class Solver2Tests < Minitest::Test
  def test_compare
    # 3,9,8,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
    programm = [3,9,8,9,10,9,4,9,99,-1,8]
    assert_equal 1, IntCode.new(programm, 8).output.first
    assert_equal 0, IntCode.new(programm, 7).output.first
  end
  
  def test_compare_less
    # 3,9,7,9,10,9,4,9,99,-1,8 - Using position mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
    programm = [3,9,7,9,10,9,4,9,99,-1,8]
    assert_equal 1, IntCode.new(programm, 7).output.first
    assert_equal 0, IntCode.new(programm, 8).output.first
  end
  
  def test_compare_equal
    # 3,3,1108,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
    programm = [3,3,1108,-1,8,3,4,3,99]
    assert_equal 1, IntCode.new(programm, 8).output.first
    assert_equal 0, IntCode.new(programm, 7).output.first
  end

  def test_compare_less_immediate
    # 3,3,1107,-1,8,3,4,3,99 - Using immediate mode, consider whether the input is less than 8; output 1 (if it is) or 0 (if it is not).
    programm = [3,3,1107,-1,8,3,4,3,99]
    assert_equal 1, IntCode.new(programm, 7).output.first
    assert_equal 0, IntCode.new(programm, 8).output.first
  end

  def test_jump
    # Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:
    # 3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 (using position mode)
    programm = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    assert_equal 1, IntCode.new(programm, 1).output.first
    assert_equal 0, IntCode.new(programm, 0).output.first
  end
  def test_jump_2
    # Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:
    # 3,3,1105,-1,9,1101,0,0,12,4,12,99,1 (using immediate mode)
    programm = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    assert_equal 1, IntCode.new(programm, 1).output.first
    assert_equal 0, IntCode.new(programm, 0).output.first
  end
end




class IntCode
  attr_reader :memory, :output
  # array of numbers
  def initialize(programm, input = 0, fix: false)
    @memory = programm.map(&:to_i)
    @input = input
    @output = []
    @computed = false
    fix_programm if fix
    # instruction_pointer
    @address = 0
  end

  def compute
    return terminate if @memory[@address] == 99

    # opcode
    case opcode
    when 1
      binding.pry unless param(1) && param(2)
      @memory[param(3, write_mode: true)] = param(1) + param(2)
      go_to_next_address
    when 2
      @memory[param(3, write_mode: true)] = param(1) * param(2)
      go_to_next_address
    when 3
      @memory[param(1, write_mode: true)] = @input
      go_to_next_address
    when 4
      @output << param(1)
      go_to_next_address
    when 5
      if param(1) != 0
        @address = param(2)
      else
        go_to_next_address
      end
    when 6
      if param(1) == 0
        @address = param(2)
      else
        go_to_next_address
      end
    when 7
      out = param(1) < param(2) ? 1 : 0
      @memory[param(3, write_mode: true)] = out
      go_to_next_address
    when 8
      out = param(1) == param(2) ? 1 : 0
      @memory[param(3, write_mode: true)] = out
      go_to_next_address
    end

#     Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
#   Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
# Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
# Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.

    compute
  end

  def opcode
    @memory[@address].to_s.rjust(2).chars[(-2..-1)].join.to_i
  end

  def instruction
    length = opcode_number_of_param + 2
    @memory[@address].to_s.rjust(length)
  end

  def go_to_next_address
    @address += opcode_number_of_param + 1
  end

  def opcode_number_of_param
    {1 => 3, 2 => 3, 3 => 1, 4 => 1, 5 => 2, 6 => 2, 7 => 3, 8 => 3}[opcode]
  end

  def memory
    compute unless @computed
    @memory
  end

  def result
    compute unless @computed
    @memory[0]
  end

  def output
    compute unless @computed
    @output
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
  end

  # parameters
  def param(offset, write_mode: false )
    param_mode = instruction.chars.reverse[offset+1].to_i
    param_mode = 1 if write_mode # Parameters that an instruction writes to will never be in immediate mode.
    value = @memory[@address + offset]
    if param_mode == 0 # position mode
      @memory[value]
    else # immediate mode
      value
    end
  end

  def fix_programm
    noun = 12
    verb = 2
  end
end


PUZZLE_INPUT = File.open('5.dat').readlines.join.split(",")
runner = IntCode.new(PUZZLE_INPUT, 1, fix: false)
puts runner.output.last

runner = IntCode.new(PUZZLE_INPUT, 5, fix: false)
puts runner.output.last
binding.pry

# runner.compute
# binding.pry

