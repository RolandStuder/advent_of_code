require 'pry'
require 'minitest'
require 'minitest/autorun'


class Group
  def initialize(group_string)
    @people = group_string.split.map{ |line| Person.new(line)}
  end

  def yes_count
    answered_yes.count
  end

  def all_yes_count
    answered_yes.count do |question|
      @people.all? { |person| person.answers.include?(question) }
    end
  end

  def answered_yes
    @people.collect(&:answers).flatten.uniq
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

  def test_all_yes_example
    groups = TEST_INPUT.split("\n\n").map { |entry| Group.new(entry)}
    sum_count = groups.collect(&:all_yes_count).sum
    assert_equal 6, sum_count
  end
end


puts "Solution 1"

groups = File.read("6.dat").split("\n\n").map { |entry| Group.new(entry)}
sum_count = groups.collect(&:yes_count).sum
puts sum_count

puts "Solution 2"

sum_all_yes_count = groups.collect(&:all_yes_count).sum
puts sum_all_yes_count
