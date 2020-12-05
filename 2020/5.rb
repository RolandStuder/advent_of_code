require 'pry'
require 'minitest'
require 'minitest/autorun'


class BoardingPass
  def initialize(code)
    @code = code
  end

  def row
    binary_code[0..6].to_i(2)
  end

  def column
    binary_code[7..9].to_i(2)
  end

  def seat_id
    row * 8 + column
  end

  def binary_code
    @code.chars.map { |char| char == "B" || char == "R" ? 1 : 0}.join
  end
end


class DocumentTest < Minitest::Test
  def test_example
    # BFFFBBFRRR: row 70, column 7, seat ID 567.
    pass = BoardingPass.new("BFFFBBFRRR")
    assert_equal 70, pass.row
    assert_equal 7, pass.column
    assert_equal 567, pass.seat_id
  end
end


puts "Solution 1"

passes = File.readlines("5.dat").map{ |line| BoardingPass.new(line) }
puts passes.max_by { |pass| pass.seat_id }.seat_id
