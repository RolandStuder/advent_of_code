require 'pry'
require 'minitest'
require 'minitest/autorun'

# Before you leave, the Elves in accounting just need you to fix your expense report (your puzzle input); apparently, something isn't quite adding up.
#
# Specifically, they need you to find the two entries that sum to 2020 and then multiply those two numbers together.
#
# For example, suppose your expense report contained the following:
#
# 1721
# 979
# 366
# 299
# 675
# 1456
# In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying them together produces 1721 * 299 = 514579, so the correct answer is 514579.
#
# Of course, your expense report is much larger. Find the two entries that sum to 2020; what do you get if you multiply them together?
#

# report = File.readlines('1.dat').map(&:to_i)

class ExpenseReport
  def initialize(numbers)
    @entries = numbers
  end

  def elements_for_sum(sum = 2020 )
    @entries.each do |number|
      complement = sum - number
      if @entries.include? complement
        return number, complement
      end
    end
  end

  def three_elements_for_sum(sum = 2020)
    @entries.each do |number|
      complement = sum - number
      if all_sums.include? complement
        return [number, all_sums[complement]].flatten
      end
    end
  end

  def all_sums
    return @sums if @sums

    @sums = {}
    @entries.each_with_index do |a, index|
       @entries[(index+1)..].each do |b|
         @sums[(a+b)] = [a,b]
       end
    end
    @sums
  end

  def result
    factor_1, factor_2 = elements_for_sum
    factor_1 * factor_2
  end

  def result_2
    factor_1, factor_2, factor_3 = three_elements_for_sum
    factor_1 * factor_2 * factor_3
  end

  def easy_solution(summands=2)
    @entries.combination(summands).find { |elements| elements.sum == 2020}.reduce(&:*)
  end
end

class ExpenseReportTest < Minitest::Test
  def test_example_one
    example_data = [1721, 979, 366, 299, 675, 1456]
    assert_equal 514579, ExpenseReport.new(example_data).result
  end

  def test_all_sums
    data = [1,2,3]
    assert_equal ({3=>[1, 2], 4=>[1, 3], 5=>[2, 3]}), ExpenseReport.new(data).all_sums
  end

  def test_example_two
    data = [979, 366, 675]
    assert_equal [979, 366, 675], ExpenseReport.new(data).three_elements_for_sum
    # assert_equal 241861950, ExpenseReport.new(data).result_2
  end

end

numbers = File.readlines('1.dat').map(&:to_i)

puts "1" * 10
puts
puts ExpenseReport.new(numbers).result
puts
puts "1" * 10
puts
puts "2" * 10
puts
puts ExpenseReport.new(numbers).result_2
puts ExpenseReport.new(numbers).easy_solution(3)
puts
puts "2" * 10

