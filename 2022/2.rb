require "minitest/autorun"
require "./lib/parsing_helper"

class RockPaperScissorsRound
  attr_reader :opponent, :me
  MAPPINGS = {
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors,
    "X" => :rock,
    "Y" => :paper,
    "Z" => :scissors
  }

  def self.from_string(string)
    first, second = string.split
    new(MAPPINGS[first], MAPPINGS[second])
  end

  def self.from_string_second_column_indicates_targeted_result(string)
    first, second = string.split
    opponent = MAPPINGS[first]
    if second == "Y" # draw
      me = opponent
    elsif second == "X" # loose
      me = {
        rock: :scissors,
        paper: :rock,
        scissors: :paper
      }[opponent]
    else
      me = {
        rock: :scissors,
        paper: :rock,
        scissors: :paper
      }.invert[opponent]
    end

    new(opponent, me)
  end

  def initialize(opponent, me)
    @opponent = opponent
    @me = me
  end

  def score
    shape_score + fight_score
  end

  def shape_score
    {
      rock: 1,
      paper: 2,
      scissors: 3
    }[me]
  end

  def fight_score
    if @opponent == @me
      3
    elsif @opponent == :rock && @me == :scissors
      0
    elsif @opponent == :paper && @me == :rock
      0
    elsif @opponent == :scissors && @me == :paper
      0
    else
      6
    end
  end

end

class Day1Test < Minitest::Test
  TEST_INPUT = %{A Y
B X
C Z}

  def test_part_example
    scores = TEST_INPUT.split("\n").map do |line|
      RockPaperScissorsRound.from_string(line).score
    end
    assert_equal 15, scores.sum
  end
end

scores = ParsingHelper.load(2022, 2).lines.map do |line|
  RockPaperScissorsRound.from_string(line).score
end

puts "PART 1:"
puts scores.sum



scores = ParsingHelper.load(2022, 2).lines.map do |line|
  RockPaperScissorsRound.from_string_second_column_indicates_targeted_result(line).score
end

puts "PART 2:"
puts scores.sum
