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

  def elements_for_sum(sum= 2020)
    @entries.each do |number|
      complement = sum - number
      if @entries.include? complement
        return number, complement
      end
    end
  end

  def result
    factor_1, factor_2 = elements_for_sum
    factor_1 * factor_2
  end
end

class ExpenseReportTest < Minitest::Test
  def test_example_one
    example_data = [1721, 979, 366, 299, 675, 1456]
    assert_equal 514579, ExpenseReport.new(example_data).result
  end
end


numbers = File.readlines('1.dat').map(&:to_i)
puts "RESULT" * 10
puts
puts ExpenseReport.new(numbers).result
puts
puts "RESULT" * 10
