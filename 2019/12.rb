require 'pry'
require 'minitest'
require 'set'


class Moon
  attr_reader :position, :velocity

  def initialize(coord)
    @position = coord
    @velocity = [0,0,0]
    @history = Set[]
  end

  def apply_gravity(coord)
    coord.each_with_index do |other, index|
      if other > @position[index]
        @velocity[index] += 1
      elsif other < @position[index]
        @velocity[index] -= 1
      end
    end
  end

  def apply_velocity
    @position.each_with_index do |_, index|
      @position[index] += @velocity[index]
    end
    @history.size if @history.include?(@position + @velocity)
    @history.add(@position + @velocity)
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def potential_energy
    @position.map(&:abs).reduce(0, :+)
  end

  def kinetic_energy
    @velocity.map(&:abs).reduce(0, :+)
  end
end

class System
  attr_accessor :moons

  def initialize
    @moons = {}
  end

  def add_moon(coord)
    index = @moons.keys.size
    @moons[index] = Moon.new(coord)
  end

  def step(amount = 1)
    amount.times do
      apply_gravity
      apply_velocity
    end
  end

  def total_energy
    @moons.values.map(&:total_energy).reduce(0, :+)
  end

  private

  def apply_gravity
    @moons.values.each_with_index do |moon_a, index|
      @moons.values[(index+1)..-1].each do |moon_b|
        moon_a.apply_gravity(moon_b.position)
        moon_b.apply_gravity(moon_a.position)
      end
    end
  end

  def apply_velocity
    @moons.values.map(&:apply_velocity)
  end
end

# example 1

# <x=-1, y=0, z=2>
# <x=2, y=-10, z=-7>
# <x=4, y=-8, z=8>
# <x=3, y=5, z=-1>
#

example_1 = System.new
example_1.add_moon([-1,0,2])
example_1.add_moon([2,-10,-7])
example_1.add_moon([4,-8,8])
example_1.add_moon([3,5,-1])

example_1.step(10)
puts 179 == example_1.total_energy


# puzzle Input
#
# <x=3, y=3, z=0>
# <x=4, y=-16, z=2>
# <x=-10, y=-6, z=5>
# <x=-3, y=0, z=-13>

system = System.new
system.add_moon([3, 3, 0])
system.add_moon([4, -16, 2])
system.add_moon([-10, -6, 5])
system.add_moon([-3, 0, -13])



puts "result system 1:"
puts system.total_energy

puts "ms per step: "
start = Time.now
system.step(1000)
puts "system 1 : " + ((Time.now - start)*1000).to_i.to_s

# So let's think about this...
# vectors increase +1 -1 per step, so a pair of moons,
# will ignoring others, keep increasing / decreasing each others values
# so, the planet at the lowest position x will get +3 the other +1 -1 -3 in velocity
# this is true for all dimensions

# i need to turn it upside down, and track the the moons dimension positions instead of the moons.
class System_2
  def initialize
    # keeps id, positions and velocities
    # id, position, velocity
    @dimensions = [[],[],[]]
  end

  def moons
    memo = {0 => [], 1 => [], 2 => [], 3 => []}
    @dimensions.each do |dim|
      dim.each do |m|
        memo[m[0]] << [m[1], m[2]]
      end
    end
    memo.map do |moon|
      moon.flatten!
      moon.shift
      {
        position: {
            x: moon[0],
            y: moon[2],
            z: moon[4]
        },
        velocity: {
            x: moon[1],
            y: moon[3],
            z: moon[5]
        }
      }
    end
  end

  def step(amount = 1)
    amount.times {
        apply_gravity
    }
  end
  # moon is [x,y,z,dx,dy,dz]
  def add_moon(coord)
    id = @dimensions[0].length
    coord.each_with_index do |c,i|
      @dimensions[i] << [id,c,0]
    end
  end

  def apply_gravity
    @dimensions.map do |moons|
      moons.sort_by!{ |m| m[1] }
      i = 0
      # cannot map. because of multiples
      # i could make a function that calculates the next stuff until it crosses again
      while i < moons.size
        m = moons[i]
        unless moons[i+1] && moons[i+1][1] == m[1]
          moons[i][2] += 3 - 2 * i
          moons[i][1] += m[2]
          i += 1
        else
          same_count = moons[i..-1].count{ |s| s[1] == m[1]}
          # 0110 -> 0   | 1 l 2
          # 1100 -> 2   | 0 l 2
          # 1110 -> 1   | 0 l 3
          # 1111 -> 0   | 0 l 4
          # 0111 -> -1  | 1 l 3
          # 0011 -> -2  | 3 l 2 -> how many left, how many right
          left = i
          right = 4 - same_count - i
          delta = -(left - right)
          (0..(same_count-1)).each do |j|
            moons[j+i][2] += delta
            moons[j+i][1] += moons[j+i][2]
          end
          i += same_count
        end
      end
      moons
    end
  end

  def total_energy
    potential_energy = moons.inject(0) do |sum, moon|
      potential_energy = moon[:position].values.map(&:abs).reduce(0, :+)
      kinetic_energy= moon[:velocity].values.map(&:abs).reduce(0, :+)
      sum += potential_energy * kinetic_energy
    end
  end
end

system_2 = System_2.new
system_2.add_moon([3, 3, 0])
system_2.add_moon([4, -16, 2])
system_2.add_moon([-10, -6, 5])
system_2.add_moon([-3, 0, -13])


example_1 = System_2.new
example_1.add_moon([-1,0,2])
example_1.add_moon([2,-10,-7])
example_1.add_moon([4,-8,8])
example_1.add_moon([3,5,-1])

example_1.step(10)
puts example_1.total_energy
puts 179 == example_1.total_energy


start = Time.now

system_2.step(1000)

puts "result system 2:"
puts system.total_energy

puts "system 2 : " + ((Time.now - start)*1000).to_i.to_s


class System_3
  def initialize
    # keeps id, positions and velocities
    # id, position, velocity
    @dimensions = [[],[],[]]
  end

  def moons
    memo = {0 => [], 1 => [], 2 => [], 3 => []}
    @dimensions.each do |dim|
      dim.each do |m|
        memo[m[0]] << [m[1], m[2]]
      end
    end
    memo.map do |moon|
      moon.flatten!
      moon.shift
      {
          position: {
              x: moon[0],
              y: moon[2],
              z: moon[4]
          },
          velocity: {
              x: moon[1],
              y: moon[3],
              z: moon[5]
          }
      }
    end
  end

  def step(amount = 1)
    amount.times {
      apply_gravity
    }
  end
  # moon is [x,y,z,dx,dy,dz]
  def add_moon(coord)
    id = @dimensions[0].length
    coord.each_with_index do |c,i|
      @dimensions[i] << [id,c,0]
    end
  end

  def apply_gravity
    @dimensions.map do |moons|
      dimension_gravity(moons)
    end
  end

  def find_dimension_cycle(dim)
    dimension = @dimensions[dim]
    initial_state = dimension.clone.map(&:clone)
    counter = 0
    loop do
      dimension = dimension_gravity(dimension)
      counter += 1
      dimension.sort_by!{ |m| m[0] } # a hash would have been better for this
      if counter % 2772 == 0
        puts counter
      end
      break if dimension == initial_state
    end
    counter
  end

  def cycle_length
    cycle = (0..2).map{ |d| find_dimension_cycle(d)}
    cycle.reduce(1, :lcm)
  end

  def dimension_gravity(moons)
    moons.sort_by!{ |m| m[1] }
    i = 0
    # cannot map. because of multiples
    # i could make a function that calculates the next stuff until it crosses again
    while i < moons.size
      m = moons[i]
      unless moons[i+1] && moons[i+1][1] == m[1]
        moons[i][2] += 3 - 2 * i
        moons[i][1] += m[2]
        i += 1
      else
        same_count = moons[i..-1].count{ |s| s[1] == m[1]}
        # 0110 -> 0   | 1 l 2
        # 1100 -> 2   | 0 l 2
        # 1110 -> 1   | 0 l 3
        # 1111 -> 0   | 0 l 4
        # 0111 -> -1  | 1 l 3
        # 0011 -> -2  | 3 l 2 -> how many left, how many right
        left = i
        right = 4 - same_count - i
        delta = -(left - right)
        (0..(same_count-1)).each do |j|
          moons[j+i][2] += delta
          moons[j+i][1] += moons[j+i][2]
        end
        i += same_count
      end
    end
    moons
  end

  def total_energy
    potential_energy = moons.inject(0) do |sum, moon|
      potential_energy = moon[:position].values.map(&:abs).reduce(0, :+)
      kinetic_energy= moon[:velocity].values.map(&:abs).reduce(0, :+)
      sum += potential_energy * kinetic_energy
    end
  end
end


system_3 = System_3.new
system_3.add_moon([3, 3, 0])
system_3.add_moon([4, -16, 2])
system_3.add_moon([-10, -6, 5])
system_3.add_moon([-3, 0, -13])


example_3 = System_3.new
example_3.add_moon([-1,0,2])
example_3.add_moon([2,-10,-7])
example_3.add_moon([4,-8,8])
example_3.add_moon([3,5,-1])

example_3.step(10)
puts example_3.total_energy
puts 179 == example_1.total_energy


start = Time.now

puts "result system 3:"
puts system.total_energy

system_3.step(1_000)

puts "system 3 : " + ((Time.now - start)*1000).to_i.to_s

# system_3 = System_3.new
# system_3.add_moon([3, 3, 0])
# system_3.add_moon([4, -16, 2])
# system_3.add_moon([-10, -6, 5])
# system_3.add_moon([-3, 0, -13])
#
# puts x = system_3.find_dimension_cycle(0)
# puts y = system_3.find_dimension_cycle(1)
# puts z = system_3.find_dimension_cycle(2)

example_1 = System_3.new
example_1.add_moon([-1,0,2])
example_1.add_moon([2,-10,-7])
example_1.add_moon([4,-8,8])
example_1.add_moon([3,5,-1])

puts "exmple 1 cycle length " + example_1.cycle_length.to_s


system_3 = System_3.new
system_3.add_moon([3, 3, 0])
system_3.add_moon([4, -16, 2])
system_3.add_moon([-10, -6, 5])
system_3.add_moon([-3, 0, -13])

puts "puzzle input cycle length " + system_3.cycle_length.to_s


# {<x=-8, y=-10, z=0>
# <x=5, y=5, z=10>
# <x=2, y=-7, z=3>
# <x=9, y=-8, z=-3>
# }# This set of initial positions takes 4686774924 steps before it repeats a previous state!
