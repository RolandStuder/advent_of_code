# ruby -Ilib:test 2021/4.rb
require "minitest/autorun"

class BingoGame
  attr_accessor :drawn_numbers, :boards

  def self.from_parser(parser)
    game = new
    game.drawn_numbers = parser.drawn_numbers
    parser.boards.each do |board|
      game.boards << Board.new(board)
    end
    game
  end

  def initialize
    self.boards = []
  end

  def find_winning_board
    drawn_numbers.each do |number|
      boards.each { |board| board.mark(number) }
      winning_board = boards.find(&:win?)
      return winning_board if winning_board
    end
  end

  def find_loosing_board
    board_that_have_not_won = boards.dup
    drawn_numbers.each do |number|
      board_that_have_not_won.each { |board| board.mark(number) }
      board_that_have_not_won.reject!(&:win?) if board_that_have_not_won.size > 1
      return board_that_have_not_won.first if board_that_have_not_won.first.win?
    end
  end
end

class Board
  attr_accessor :marked_numbers
  def initialize(array)
    @data = array
    @marked_numbers = []
  end

  def win?
    @data.any? { |row| (row - marked_numbers).empty? } ||
      @data.transpose.any? { |column| (column - marked_numbers).empty? }
  end

  def mark(number)
    self.marked_numbers << number
  end

  def unmarked_numbers
    @data.flatten - marked_numbers
  end

end

class Day4Parser
  # as lines
  def initialize(input)
    @raw = input
  end

  def drawn_numbers
    @raw.split("\n").first.split(",").map(&:to_i)
  end

  def boards
    @boards = []
    @raw.split("\n")[2..].each_slice(6) do |board|
      @boards << board.first(5).map do |line|
        line.split.map(&:to_i)
      end
    end
    @boards
  end
end



class Day4 < Minitest::Test
  def test_example_input
    example_input = %{7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7}

    parser = Day4Parser.new(example_input)
    assert_equal 7, parser.drawn_numbers.first
    assert_equal 1, parser.drawn_numbers.last

    assert_equal 5, parser.boards.first.size
    assert_equal 19, parser.boards.first.last.last

    game = BingoGame.from_parser(parser)
    winning_board = game.find_winning_board
    assert_equal 188, winning_board.unmarked_numbers.sum
    assert_equal 4512, winning_board.unmarked_numbers.sum * winning_board.marked_numbers.last

    loosing_board = game.find_loosing_board
    assert_equal 1924, loosing_board.unmarked_numbers.sum * loosing_board.marked_numbers.last
  end
end


# PART 1
#
parsed = Day4Parser.new(File.open('2021/4.data').readlines.join)
game = BingoGame.from_parser(parsed)
winning_board = game.find_winning_board
pp winning_board.unmarked_numbers.sum * winning_board.marked_numbers.last

loosing_board = game.find_loosing_board
pp loosing_board.unmarked_numbers.sum * loosing_board.marked_numbers.last