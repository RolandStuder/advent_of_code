# ruby -Ilib:test 2021/3.rb
require "minitest/autorun"

class DiagnosticReport
  def initialize(data)
    @data = data
  end

  def most_common_digits_per_column(selected_rows = nil)
    selected_rows ||= @data.split("\n").map(&:strip).map(&:chars)
    selected_columns ||= selected_rows.transpose
    tallies = selected_columns.map(&:tally)
    tallies.map do |tally|
      tally["0"] ||= 0
      tally["1"] ||= 0
      tally["1"] >= tally["0"] ? "1" : "0"
    end.join
  end

  def gamma_rate
    most_common_digits_per_column.to_i(2)
  end

  def epsilon_rate
    most_common_digits_per_column.chars.map { |char|
      char == "0" ? 1 : 0
    }.join.to_i(2)
  end

  def power_consumption
    gamma_rate * epsilon_rate
  end

  def oxygen_generator_rating
    length = @data.split("\n").first.size
    selected_rows =  @data.split("\n").map(&:strip).map(&:chars)
    length.times do |index|
      most_common = most_common_digits_per_column(selected_rows)[index]
      selected_rows.select! { |row| row[index] == most_common }
      return selected_rows.first.join.to_i(2) if selected_rows.size == 1
    end
  end

  def co2_scrubber_rating
    length = @data.split("\n").first.size
    selected_rows =  @data.split("\n").map(&:strip).map(&:chars)
    length.times do |index|
      least_common = (most_common_digits_per_column(selected_rows)[index] == "0" ? "1" : "0")
      selected_rows.select! { |row| row[index] == least_common }
      return selected_rows.first.join.to_i(2) if selected_rows.size == 1
    end
  end

  def life_support_rating
    co2_scrubber_rating * oxygen_generator_rating
  end

end



class Day3 < Minitest::Test
  def test_example_input
    example = %{00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010}
    report = DiagnosticReport.new(example)
    assert_equal "10110", report.most_common_digits_per_column
    assert_equal 22, report.gamma_rate
    assert_equal 9, report.epsilon_rate
    assert_equal  198, report.power_consumption
    assert_equal  23, report.oxygen_generator_rating
    assert_equal  10, report.co2_scrubber_rating
    assert_equal  10, report.co2_scrubber_rating
    assert_equal 230, report.life_support_rating
  end
end


# PART 1
#

report = DiagnosticReport.new(File.open('2021/3.data').readlines.join)
pp report.power_consumption
pp report.life_support_rating
