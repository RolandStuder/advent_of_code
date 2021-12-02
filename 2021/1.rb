# ruby -Ilib:test 2021/1.rb
require "minitest/autorun"

class Sonar
  attr_accessor :data

  def increases(window_size = 1)
    sums = data.map.with_index do |_, index|
      if data[index + window_size - 1]
        data[index..(index + window_size - 1)].sum
      end
    end
    sums.compact!
    sums.select.with_index { |sum, index|
      next unless sums[index-1]
      sum > sums[index-1]
    }.count
  end
end


class TestMeme < Minitest::Test
  def test_example_input
    example_input = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
    sonar = Sonar.new
    sonar.data = example_input
    assert_equal 7, sonar.increases
  end

  def test_example_input_with_window
    example_input = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
    sonar = Sonar.new
    sonar.data = example_input
    assert_equal 5, sonar.increases(3)
  end

end

sonar = Sonar.new
sonar.data = File.readlines('2021/1.data').map(&:to_i)
puts sonar.increases
puts sonar.increases(3)

