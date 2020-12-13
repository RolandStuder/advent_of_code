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

  def find_faster
    highest = @buses.keys.max
    n = 1
    loop do
      result, x , n = minimal_multiplicators(highest, @buses[highest], start_at: n)
      return result if @buses.all? do |time, delta|
        (result + delta) % time == 0
      end
      puts result
      n += 1
    end
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
end

puts "Solution 2"

puts FindTime.new("1789,37,47,1889").find_faster.to_i
# puts FindTime.new(data[1]).find_faster.to_i



# 4, x, 5
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
# n -> (% * 2 - 2) / 4 -> ganzzahlig
# m mind 2
# n mind 2



