require 'pry'
require 'minitest'
require 'minitest/autorun'


class Group
  def initialize(group_string)
    @people = group_string.split.map{ |line| Person.new(line)}
  end

  def yes_count
    @people.collect(&:answers).flatten.uniq.count
  end
end

class Person
  attr_reader :answers
  def initialize(answer_string)
    @answers = answer_string.chars
  end
end


class DeclarationsTest < Minitest::Test
  TEST_INPUT = %{
abc

a
b
c

ab
ac

a
a
a
a

b
}

  def test_example
    groups = TEST_INPUT.split("\n\n").map { |entry| Group.new(entry)}
    sum_count = groups.collect(&:yes_count).sum
    assert_equal 11, sum_count
  end
end


puts "Solution 1"

groups = File.read("6.dat").split("\n\n").map { |entry| Group.new(entry)}
sum_count = groups.collect(&:yes_count).sum
puts sum_count

puts "Solution 2"

