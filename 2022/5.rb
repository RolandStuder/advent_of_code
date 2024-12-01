require "minitest/autorun"
require "./lib/parsing_helper"

class CratePilings
  def self.from_plan_string(string)
    pilings = new
    lines = string.split("\n")[0..-2].reverse # without last lines
    lines.each do |line|
      line.chars.each_slice(4).with_index(1) do |slice, index|
        pilings.add(slice[1], column: index)
      end
    end
    pilings
  end

  def initialize
    @columns = Hash.new { |h, k| h[k] = [] }
  end

  def add(*values, column:)
    values.each do |value|
      @columns[column] << value unless value == " "
    end
  end

  def column(number)
    @columns[number]
  end
  alias_method :[], :column

  def top(number)
    column(number).last
  end

  def move(amount, from:, to:)
    values = column(from.to_i).pop(amount.to_i)
    add(*values.reverse, column: to.to_i)
  end

  def modern_move(amount, from:, to:)
    values = column(from.to_i).pop(amount.to_i)
    add(*values, column: to.to_i)
  end

  def topline
    @columns.values.map(&:last)
  end
end

class Day5Test < Minitest::Test
  TEST_INPUT = %{    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2}

  def test_part_example
    plan, instructions = TEST_INPUT.split("\n\n")
    pilings = CratePilings.from_plan_string(plan)
    assert_equal "N", pilings.top(1)
    assert_equal "D", pilings.top(2)
    assert_equal "P", pilings.top(3)

    instructions.split("\n").each do |instruction|
      match = instruction.match(/move (?<amount>\d)+ from (?<from>\d)+ to (?<to>\d)+/)
      pilings.move(match[:amount], from: match[:from], to: match[:to])
    end
    assert_equal "Z", pilings.column(3).last
    assert_equal "CMZ", pilings.topline.join
  end
end

puts "Part 1:"
plan, instructions =  ParsingHelper.load(2022, 5).raw.split("\n\n")
pilings = CratePilings.from_plan_string(plan)

instructions.split("\n").each do |instruction|
  match = instruction.match(/move (?<amount>\d+) from (?<from>\d+) to (?<to>\d+)/)

  pilings.move(match[:amount], from: match[:from], to: match[:to])
end

puts pilings.topline.join

puts "Part 2:"
plan, instructions =  ParsingHelper.load(2022, 5).raw.split("\n\n")
pilings = CratePilings.from_plan_string(plan)

instructions.split("\n").each do |instruction|
  match = instruction.match(/move (?<amount>\d+) from (?<from>\d+) to (?<to>\d+)/)

  pilings.modern_move(match[:amount], from: match[:from], to: match[:to])
end

puts pilings.topline.join

puts "Part 3:"
time = Time.now
plan, instructions =  ParsingHelper.load(2022, 6).raw.split("\n\n")
pilings = CratePilings.from_plan_string(plan)

instructions.split("\n").each do |instruction|
  match = instruction.match(/move (?<amount>\d+) from (?<from>\d+) to (?<to>\d+)/)

  pilings.modern_move(match[:amount], from: match[:from], to: match[:to])
end

puts pilings.topline.join
time_taken = Time.now - time
puts "took #{time_taken.to_i}"
