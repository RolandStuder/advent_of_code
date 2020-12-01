

# --- Day 1: The Tyranny of the Rocket Equation ---
# Santa has become stranded at the edge of the Solar System while delivering presents to other planets! To accurately calculate his position in space, safely align his warp drive, and return to Earth in time to save Christmas, he needs you to bring him measurements from fifty stars.

# Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

# The Elves quickly load you into a spacecraft and prepare to launch.

# At the first Go / No Go poll, every Elf is Go until the Fuel Counter-Upper. They haven't determined the amount of fuel required yet.

# Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.

# For example:

# For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
# For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
# For a mass of 1969, the fuel required is 654.
# For a mass of 100756, the fuel required is 33583.
# The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.

# What is the sum of the fuel requirements for all of the modules on your spacecraft?

require 'pry'
require_relative 'lib/string.rb'
require 'minitest'
require "minitest/autorun"

PUZZLE_INPUT_1 = "98435
61869
123694
51157
70664
107632
60289
140493
135101
89758
142578
63389
126315
133069
139989
121089
148127
117475
65718
129198
98612
67678
79752
97930
141835
80575
125798
114298
139861
75550
64724
76315
71871
132949
117877
57157
93756
113889
60388
145810
86668
94498
50502
106789
119505
65341
60103
75963
104149
134483
92833
102273
56988
74202
69016
110217
132242
87186
95704
88433
56225
60206
70508
62692
143847
70088
129908
133319
104284
108627
106977
107696
59576
76422
115945
137414
83299
138678
108034
140276
74857
143726
116028
101970
84298
133544
116069
77564
91964
57954
121404
54416
83370
74842
91677
65323
82036
138725
95805
112490".freeze

class FuelCalculator
  def self.mass_to_fuel(mass)
    (mass.to_f / 3).floor - 2
  end
end

class Mod
  attr_accessor :mass, :fuel

  def initialize(mass: 0)
    @mass = mass
    @fuel = 0
  end

  def fuel_needed(mass = @mass, total = 0)
    new_fuel = FuelCalculator.mass_to_fuel(mass)
    return total if new_fuel <= 0
    total += new_fuel
    fuel_needed(new_fuel, total)
  end
end

class Spacecraft
  attr_accessor :mods

  def initialize(mods: [])
    @mods = mods
  end

  def fuel_needed
    @mods.map{ |mod| mod.fuel_needed}.sum
  end
end

class FuelCalcalculation < Minitest::Test
  def setup
    @module = Mod.new
  end

  # For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
  # For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
  # For a mass of 1969, the fuel required is 654.
  # For a mass of 100756, the fuel required is 33583.
  # The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.
  def test_step_1
    assert_equal FuelCalculator.mass_to_fuel( 12 ), 2
    assert_equal FuelCalculator.mass_to_fuel( 14 ), 2
    assert_equal FuelCalculator.mass_to_fuel( 1969 ), 654
    assert_equal FuelCalculator.mass_to_fuel( 100756 ), 33583
  end

  def test_calculate_sum_of_fuels
    masses = [14,1969]
    fuel = masses.map{ |m| FuelCalculator.mass_to_fuel(m)}
    assert_equal (2 + 654), fuel.sum
  end

  # A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
  # At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
  # The fuel required by a module of mass 100756 and its fuel is: 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
  def test_step_2
    assert_equal Mod.new(mass: 14).fuel_needed, 2 
    assert_equal Mod.new(mass: 1969).fuel_needed, 966 
    assert_equal Mod.new(mass: 100756).fuel_needed, 50346 
  end

end

masses = PUZZLE_INPUT_1.split("\n").map(&:to_i)
fuel = masses.map{ |m| FuelCalculator.mass_to_fuel(m)}


### ANSWER STEP 1
puts "*" * 40
puts "Fuel Needed flat"
puts fuel.sum
puts "*" * 40

### STEP 2

modules = masses.map{ |mass| Mod.new(mass: mass)}
spacecraft = Spacecraft.new(mods: modules)


puts "*" * 40
puts "Fuel Needed Total"
puts spacecraft.fuel_needed.to_s.big
puts "*" * 40

# TIL

# * A calculator you only use in one model, might still be worth extracting, if there are good chances of reuse, as you also have to adjust the tests.
# * TDD is a clear winner here, keep that up
# * Recursive is still hard for me, because I forgot about the memoization part
# * Fucking be sure, you put the right numbers into your tests! -> better to have seperate test cases than multiple asserts, as the test might fail as a whole