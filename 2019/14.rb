require 'pry'
require 'minitest'
require 'minitest/autorun'

EXAMPLE_1 = "10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL"

EXAMPLE_2 = "9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL"

EXAMPLE_3 = "157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"

EXAMPLE_4 = "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF"

EXAMPLE_5 = "171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX"


class NanoFactory
  attr_reader :reactions
  def initialize(recipe_input)
    @reactions = {}
    @recipe = parse(recipe_input)
  end

  def ore_required(amount = 1)
    gather_resources_needed(:FUEL, amount)[:ORE]
  end

  private

  def parse(recipe)
    lines = recipe.split("\n")
    lines.each do |line|
      reaction = Reaction.new(line)
      @reactions[reaction.output] = reaction
    end
  end

  def gather_resources_needed(resource = :FUEL, amount = 1)
    @resources = {}
    @left_overs = {}
    @resources[resource] = amount
    while @resources.keys.any? { |key| key != :ORE}
      new_resources = {}
      @resources.each do |r, a|
        a = deduct_from_left_overs(r,a)
        if r == :ORE
          if new_resources[:ORE]
            new_resources[:ORE] += a
          else
            new_resources[:ORE] = a
          end
        else
          needed, left_over = (@reactions[r].run(a))
          if @left_overs[r]
            @left_overs[r] += left_over
          else
            @left_overs[r] = left_over
          end
          needed.each do |n_r, n_a|
            if new_resources[n_r]
              new_resources[n_r] += n_a
            else
              new_resources[n_r] = n_a
            end
          end
        end
      end
      puts "*" * 80
      puts @resources
      puts @left_overs
      @resources = new_resources.dup
    end
    @resources
    #
    # new_resources = @reactions[resource].resources_needed(amount)
    # new_resources.each do |r, a|
    #   if total[r]
    #     total[r] += a
    #   else
    #     total[r] = a
    #   end
    # end
    #
  end

  private

  def deduct_from_left_overs(r,a)
    if @left_overs[r] && @left_overs[r] > 0
      remaining = a - @left_overs[r]
      if remaining <= 0
        delta = a
      else
        delta = @left_overs[r]
      end
      @left_overs[r] -= delta
      a - delta
    end
  end
end

class Reaction
  attr_reader  :output, :amount, :ingredients
  def initialize(recipe_line)
    @ingredients = {}
    parse(recipe_line)
  end

  def resources_needed(amount = @amount)
    factor = (amount.to_f / @amount).ceil
    needed = {}
    @ingredients.each do |material, amount_of|
      needed[material] = amount_of * factor
    end
    needed
  end

  def left_overs(amount = @amount)
    binding.pry unless amount
    @amount - amount % @amount
  end

  def run(amount = @amount)
    [resources_needed(amount), left_overs(amount)]
  end

  private

  def parse(line)
    return false unless line
    materials = line.split(",")
    materials << materials.pop.split("=>")
    materials.flatten!
    output = materials.last.strip.split(" ")
    @output = output[1].strip.to_sym
    @amount = output[0].strip.to_i
    materials[0..-2].each do |ingredient|
      duo = ingredient.split(" ")
      @ingredients[duo[1].strip.to_sym] = duo[0].strip.to_i
    end
  end
end


class NanoFactorTest < Minitest::Test
  def test_parse_line
    reaction = Reaction.new("10 ORE => 10 A")
    assert_equal :A, reaction.output
    assert_equal 10, reaction.amount
    assert_equal 1, reaction.ingredients.size
    assert_includes [{ORE: 10}], reaction.ingredients

    reaction_2 = Reaction.new("7 A, 1 E => 1 FUEL")
    assert_equal :FUEL, reaction_2.output
    assert_equal 1, reaction_2.amount
    assert_includes [{A: 7, E: 1}], reaction_2.ingredients
  end

  def test_parse_recipe
    recipe = EXAMPLE_1
    factory = NanoFactory.new(recipe)
    assert_equal 6, factory.reactions.size
    assert_instance_of Reaction, factory.reactions.values.first
  end

  def test_ore_calculation_example_2
    recipe = EXAMPLE_2
    factory = NanoFactory.new(recipe)
    assert_equal 165, factory.ore_required
  end

  def test_ore_calculation_example_3
    recipe = EXAMPLE_3
    factory = NanoFactory.new(recipe)
    assert_equal 13312, factory.ore_required
  end

  def test_ore_calculation_example_4
    recipe = EXAMPLE_4
    factory = NanoFactory.new(recipe)
    assert_equal 180697, factory.ore_required
  end

  def test_ore_calculation_example_5
    recipe = EXAMPLE_5
    factory = NanoFactory.new(recipe)
    assert_equal 2210736, factory.ore_required
  end
end



recipe = File.open('14.dat').readlines.join
factory = NanoFactory.new(recipe)
puts factory.ore_required
