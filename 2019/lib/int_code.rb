require 'pry'
require 'minitest'
require "minitest/autorun"

class IntCode
  attr_reader :memory, :output, :relative_base, :pointer
  # array of numbers
  def initialize(programm, input_value = 1, fix: false, debugger: false)
    @programm = programm.map(&:to_i)
    @memory = @programm.dup
    @input = [input_value].flatten
    @relative_base = 0
    @output = []
    @computed = false
    # instruction_pointer
    @pointer = 0
    @debug = debugger
  end

  def terminated?
    @memory[@pointer] == 99
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

  def input= value
    @computed = false
    @input = [value].flatten # so it accepts single inputs
  end

  def get_input
   @input.shift
  end

  def reset
    @input = []
    @relative_base = 0
    @memory = @programm.dup
    @output = []
    @computed = false
    @pointer = 0
  end

  def compute
    @output = []
    while @memory[@pointer] != 99
      binding.pry if @debug
      # opcode
      case opcode
      when 1
        @memory[param(3, write_mode: true)] = param(1) + param(2)
        go_to_next_instruction
      when 2
        @memory[param(3, write_mode: true)] = param(1) * param(2)
        go_to_next_instruction
      # input instruction
      when 3
        new_input = get_input
        puts  "need new input"
        break unless new_input
        @memory[param(1, write_mode: true)] = new_input
        go_to_next_instruction
      when 4
        @output << param(1)
        go_to_next_instruction
      when 5
        if param(1) != 0
          @pointer = param(2)
        else
          go_to_next_instruction
        end
      when 6
        if param(1) == 0
          @pointer = param(2)
        else
          go_to_next_instruction
        end
      when 7
        out = param(1) < param(2) ? 1 : 0
        @memory[param(3, write_mode: true)] = out
        go_to_next_instruction
      when 8
        out = param(1) == param(2) ? 1 : 0
        @memory[param(3, write_mode: true)] = out
        go_to_next_instruction
      when 9
        @relative_base += param(1)
        go_to_next_instruction
      end
    end
    terminate
    return output
  end

  private

  def opcode_number_of_param
    {1 => 3, 2 => 3, 3 => 1, 4 => 1, 5 => 2, 6 => 2, 7 => 3, 8 => 3, 9 => 1}[opcode]
  end

  def opcode
    @memory[@pointer].to_s.rjust(2).chars[(-2..-1)].join.to_i
  end

  def instruction
    length = opcode_number_of_param + 2
    @memory[@pointer].to_s.rjust(length)
  end

  def go_to_next_instruction
    @pointer += opcode_number_of_param + 1
  end

  def terminate
    @computed = true
  end

  # parameters
  def param(offset, write_mode: false )
    # 0 position mode
    # 1 immedaite mode
    # 2 relative mode
    param_mode = instruction.chars.reverse[offset+1].to_i
    if write_mode && param_mode == 0 # Parameters that an instruction writes to will never be in immediate mode.
      param_mode = 1
    end
    if write_mode && param_mode == 2 # this is so ugly, maybe I am thinking here from the wrong side
      return @memory[@pointer + offset] + @relative_base
    end

    value = @memory[@pointer + offset]
    if param_mode == 0 # position mode
      @memory[value] || 0
    elsif param_mode == 2 # relative mode
      @memory[value+@relative_base] || 0
    else # immediate mode
      value
    end
  end

  def fix_programm
    noun = 12
    verb = 2
  end
end


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

      assert_equal output.first.to_i, solver.result
    end
  end

  def test_output_programm
    programm = [3,0,4,0,99]
    input = 5
    runner = IntCode.new(programm, 5, fix: false)
    assert_equal input, runner.output.first
  end

  def test_output_programm
    programm = [1002,4,3,4,33]
    runner = IntCode.new(programm, nil, fix: false)
  end

  def test_with_negatives
    programm = [1101,100,-1,4,0]
    runner = IntCode.new(programm, nil, fix: false)
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

class Day9ExtenstionTests < Minitest::Test
  def test_setting_relative_base
    programm = [109,19,109,-20,99]
    intcode = IntCode.new(programm)
    intcode.send(:compute)
    assert_equal -1, intcode.relative_base
  end

  def test_reading_with_relative_base
    programm = [109,-1,204,1,99]
    intcode = IntCode.new(programm)
    assert_equal 109, intcode.output.last
  end

  def test_example_one
    # takes no input and produces a copy of itself as output.
    programm = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    intcode = IntCode.new(programm, debugger: false)
    assert_equal programm, intcode.output
  end

  def test_example_two_big_number
    # should output a 16-digit number.
    programm = [1102,34915192,34915192,7,4,7,99,0]
    intcode = IntCode.new(programm)
    assert_equal 16, intcode.output.last.digits.length
  end

  def test_example_three_output_large_number
    # should output the large number in the middle.
    programm = [104,1125899906842624,99]
    intcode = IntCode.new(programm)
    assert_equal 1125899906842624, intcode.output.last
  end

  def test_part_one_puzzle
    programm = File.open('9.dat').readlines.join.split(",")
    intcode = IntCode.new(programm, 1)
    assert_equal 2316632620, intcode.output.last
  end
end
