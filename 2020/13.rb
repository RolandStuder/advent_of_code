require 'pry'
require 'minitest'
require 'minitest/autorun'

data = File.readlines("13.dat")

puts "Solution 1"

timestamp = data.first.to_i
buses = (data[1].split(",") - ['x']).map(&:to_i)
delays = buses.map { |b| [b, b - (timestamp % b)] }
bus = delays.min_by{ |id, delta| delta}
puts bus[0] * bus[1]

puts "Solution 2"

class FindTime
  attr_reader :buses

  def initialize(string)
    values = string.split(",")
    non_x_values = values - ["x"]
    @buses = non_x_values.each_with_object({}) do |bus, list|
      list[bus.to_i] = values.index(bus)
    end
  end

  def base
    @buses.keys.first
  end

  def find
    current = @buses.keys.first
    increase = current
    loop do
      puts current
      return current if @buses.all? do |time, delta|
        (current + delta) % time == 0
      end
      current += increase
    end
  end

  def find_fastest
    start, delta = all_series.max_by { |value, delta| delta }
    current = start
    loop do
      return current if @buses.all? do |time, delta|
        (current + delta) % time == 0
      end
      current += delta
    end
  end

  def find_blazingly_fast
    x, dx = 0, base
    @buses.to_a[1..-1].each do |number, delta|
      x, dx = series_for_two(x, dx, delta, number)
      puts [x, dx].inspect
    end
    return dx - x
  end


  def multipliers
    @buses.to_a[1..-1].map do |number, delta|
      minimal_multiplicators(number, delta)
    end
  end

  def minimal_multiplicators(number, delta, start_at: 1)
    # seeking n and m
    x = @buses.keys.first
    (start_at..).each do |n|
      result = ((number * n - delta).to_f / x)
      if result.floor == result
        return result * x, result, n
      end
    end
  end

  def multiplicator_and_its_delta(number, delta)
    _, __, first = minimal_multiplicators(number, delta)
    _, __, second = minimal_multiplicators(number, delta, start_at: first + 1)
    its_delta = second - first
    return first, its_delta
  end

  def find_commons(number, delta)
    commons = []
    (1..).each do |n|
      commons << n*base if (n * base + delta) % number == 0
      break if commons.size >= 10
    end
    commons
  end

  def find_commons_two(x, dx, y, dy)
    commons = []
    x, dx, y, dy = y, dy, x, dx if dy > dx
    (1..).each do |n|
      commons << n*dx + x if ((n * dx + x) - y) %dy == 0
      break if commons.size == 3
    end
    commons
  end

  def series_for(number, delta)
    commons = find_commons(number, delta)
    first = commons.first
    series_delta = commons[1] - commons.first
    raise "Shit" if commons[2] - commons[1] != series_delta
    return first, series_delta
  end

  def series_for_two(x, dx, y, dy)
    commons = find_commons_two(x, dx, y, dy)
    first = commons.first
    series_delta = commons[1] - commons.first
    raise "Shit" if commons[2] - commons[1] != series_delta
    return first, series_delta
  end

  def all_series
    @buses.to_a[1..-1].map do |number, delta|
      series_for(number, delta)
    end
  end
end


describe FindTime do
  # it "find" do
  #   assert_equal 3417, FindTime.new("17,x,13,19").find_faster
  #   assert_equal 754018, FindTime.new("67,7,59,61").find_faster
  #   assert_equal 779210, FindTime.new("67,x,7,59,61").find_faster
  #   assert_equal 1261476, FindTime.new("67,7,x,59,61").find_faster
  #   assert_equal 1202161486, FindTime.new("1789,37,47,1889").find_faster
  # end

  it "finds faster" do
    assert_equal 3417, FindTime.new("17,x,13,19").find_fastest
    assert_equal 754018, FindTime.new("67,7,59,61").find_fastest
    assert_equal 779210, FindTime.new("67,x,7,59,61").find_fastest
    assert_equal 1261476, FindTime.new("67,7,x,59,61").find_fastest
    assert_equal 1202161486, FindTime.new("1789,37,47,1889").find_fastest
  end

  it "finds blazingly fast" do
    assert_equal 3417, FindTime.new("17,x,13,19").find_blazingly_fast
    assert_equal 754018, FindTime.new("67,7,59,61").find_blazingly_fast
    assert_equal 779210, FindTime.new("67,x,7,59,61").find_blazingly_fast
    assert_equal 1261476, FindTime.new("67,7,x,59,61").find_blazingly_fast
    assert_equal 1202161486, FindTime.new("1789,37,47,1889").find_blazingly_fast
  end

  it "find_commons_two wordks like normal" do
    schedule = FindTime.new("1789,37,47,1889")
    series = schedule.buses.to_a[1]
    assert_equal schedule.find_commons(series[1], series[0])[0..2], schedule.find_commons_two(0, 1789, series[0], series[1])
  end
end


puts "Solution 2"

# puts FindTime.new("1789,37,47,1889").find_fastest
puts FindTime.new(data[1]).find_blazingly_fast
binding.pry

# binding.pry

#
# 2, 10 -> 2, 12 22 32 42, .. 102k
# 3, 5 -> 3, 8, 13, 18, 23, 28, 33, 38, 43,


# 4, x, 5, 6
# a     b  c
#
# T = 4 * n
# T = 5 * m - 2

# 4 * n = 5 * m - 2
#

# 4 * n + 2
# --------- = 1
# 5 * m
#
# n = (5 * m - 2) / 4

# n = (5 * 1 - 2) / 4
#
# n -> (5 * 2 - 2) / 4 -> ganzzahlig
# m mind 2
# n mind 2



# T = 4 * a
# T = 5 * b - 2
# T = 6 * c - 3

# 4 * a = 5 * b - 2 = 6 * c - 3
# a = (5 * b - 2) / 4 = (6 * c - 3) / 4
#
# (5 * b - 2) % 4 -> (5*(b - b/5)) / 4 -> 5/4 * (b - b/5) -> 5/4 * (5b/5 - b/5) -> 5/4 * ((5 - 1)*b) / 5
#
# 5   (5 - 1)b    5*5 * (5-1)b    5 * (5-1)b                     5 * (5-1)
# - * --------- = ------------- = ---------- = ganzazhlig = b *  -------- = b GANZZAHLIG ->
# 4       5            5*4            4                             4
#
# 30/4 -> 7.5 -> 1 / 0.5 -> 2
#
# number * (number - delta)
# -------------------------
#         initial
