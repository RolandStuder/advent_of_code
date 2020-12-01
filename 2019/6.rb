require 'pry'
require 'minitest'
require "minitest/autorun"


class Universe
  attr_reader :masses

  def initialize
    @masses = {}
  end

  def mass(key)
    return nil unless key

    @masses[key.to_sym]
  end

  def add_mass(mass)
    @masses[mass.name.to_sym] = mass
  end

  def calculate_distances
    new_masses = [:COM]
    distance = 0
    while !new_masses.empty?
      new_masses.each { |m| mass(m).distance = distance }
      new_masses.map! { |m| mass(m).is_orbited_by }.flatten!
      distance += 1
    end
  end

  def calculate_ancestors_of(key)
    m = mass(key)
    ancestors = []
    while m.name != "COM"
      ancestors << mass(m.orbits).key
      m = mass(m.orbits)
    end
    mass(key).ancestors = ancestors
  end

  def distance_between(key_one, key_two)
    # warning
    calculate_ancestors_of(key_one)
    calculate_ancestors_of(key_two)
    m1 = mass(key_one)
    m2 = mass(key_two)
    common_ancestors = m1.ancestors & m2.ancestors
    # +2 for the jums tp amd from first common ancestor
    (m1.ancestors - common_ancestors).length + (m2.ancestors - common_ancestors).length + 2
  end
end

class Mass
  attr_accessor :orbits, :distance, :ancestors
  attr_reader :name, :key, :is_orbited_by

  def initialize(name)
    @name = name
    @is_orbited_by = []
  end

  def adds_orbited_by(key)
    @is_orbited_by << key.to_sym
  end

  def name
    @name.to_s
  end

  def key
    @name.to_sym
  end
end



universe = Universe.new
pairs = File.open('6.dat').readlines.map{|line| line.split(")").map(&:strip).map(&:to_sym) }

pairs.each do |pair|
  a = universe.mass(pair[0]) || universe.add_mass(Mass.new(pair[0])) 
  b = universe.mass(pair[1]) || universe.add_mass(Mass.new(pair[1]))
  b.orbits = a.key
  a.adds_orbited_by(b.key)
end

test_universe = Universe.new
pairs = File.open('6_test.dat').readlines.map{|line| line.split(")").map(&:strip).map(&:to_sym) }

pairs.each do |pair|
  a = test_universe.mass(pair[0]) || test_universe.add_mass(Mass.new(pair[0])) 
  b = test_universe.mass(pair[1]) || test_universe.add_mass(Mass.new(pair[1]))
  b.orbits = a.key
  a.adds_orbited_by(b.key)
end


universe.calculate_distances
test_universe.calculate_distances

total_distance = universe.masses.values.map(&:distance).inject(0, :+)

binding.pry


# runner.compute
# binding.pry

