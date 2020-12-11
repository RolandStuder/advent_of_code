require 'pry'
require 'minitest'
require 'minitest/autorun'

class SeatingPlan
  attr_reader :fields
  def initialize(fields = [])
    @fields = fields.each_with_index.map do |row, y|
      row.each_with_index.map  do |value, x|
        name = semantic_name_for(value)
        Field.new([x,y], name, plan: self)
      end
    end
  end

  def print
    puts "-" * 40
    @fields.each do |row|
      puts row.map(&:symbol).join
    end
  end

  def [](x,y)
    return nil unless @fields[y]
    @fields[y][x]
  end

  def []=(x,y, value)
    @fields[y] = [] unless @fields[y]
    @fields[y][x] = Field.new([x,y], value, plan: self)
  end

  def count(value)
    @fields.flatten.count { |f| f.value == value}
  end

  def width
    @fields.first.size
  end

  def height
    @fields.size
  end

  def seat_people
    new_state = SeatingPlan.new
    @fields.flatten.each do |field|
      binding.pry if field.neighbours.any?(&:nil?)
      if field.empty? && field.neighbours.none?(&:occupied?)
        new_state[field.position[0], field.position[1]] = :occupied
      elsif field.occupied? && field.neighbours.count(&:occupied?) >= 4
        new_state[field.position[0], field.position[1]] = :empty
      else
        new_state[field.position[0], field.position[1]] = field.value
      end
    end
    new_state
  end

  def seat_people_two
    new_state = SeatingPlan.new
    @fields.flatten.each do |field|
      if field.empty? && field.occupied_visible_seats == 0
        new_state[field.position[0], field.position[1]] = :occupied
      elsif field.occupied? && field.occupied_visible_seats >= 5
        new_state[field.position[0], field.position[1]] = :empty
      else
        new_state[field.position[0], field.position[1]] = field.value
      end
    end
    new_state
  end


  def self.new_from_string(input_string)
    new(input_string.split(/\n/).map(&:chars))
  end

  private

  def semantic_name_for(value)
    dict = { "L" => :empty, "#" => :occupied, "." => :floor }
    dict[value]
  end
end

class Field
  attr_reader :position, :value

  def initialize(position, value, plan:)
    @position = position
    @value = value
    @plan = plan
  end

  def symbol
    dict = { empty: "L", occupied: "#", floor: "." }
    dict[value]
  end

  def neighbours
    surrounding_positions.map do |position|
      @plan[position[0], position[1]]
    end
  end

  def occupied_visible_seats
    directions.count do |direction|
      current_position = [position[0] + direction[0], position[1] + direction[1]]
      field = @plan[current_position[0], current_position[1]]
      while field && field.floor?
        current_position = [current_position[0] + direction[0], current_position[1] + direction[1]]
        field = @plan[current_position[0], current_position[1]]
      end

      current_position[0] >= 0 &&
          current_position[1] >= 0 &&
          field &&
          field.occupied?
    end
  end

  def floor?
    value == :floor
  end

  def occupied?
    value == :occupied
  end

  def empty?
    value == :empty
  end

  private

  def surrounding_positions
    relative = (([1,0,-1].repeated_combination(2).to_a + [-1,0,1].repeated_combination(2).to_a) - [[0,0]]).uniq
    absolute = relative.map { |rel| [position[0] - rel[0], position[1] - rel[1]] }
    absolute.select do |abs|
      abs[0].between?(0, @plan.width-1) && abs[1].between?(0, @plan.height-1)
    end
  end

  def directions
    (([1,0,-1].repeated_combination(2).to_a + [-1,0,1].repeated_combination(2).to_a) - [[0,0]]).uniq
  end
end

describe SeatingPlan do
EXAMPLE_INPUT = <<~EOL
                  L.LL.LL.LL
                  LLLLLLL.LL
                  L.L.L..L..
                  LLLL.LL.LL
                  L.LL.LL.LL
                  L.LLLLL.LL
                  ..L.L.....
                  LLLLLLLLLL
                  L.LLLLLL.L
                  L.LLLLL.LL
                EOL

  before do
    @plan = SeatingPlan.new_from_string(EXAMPLE_INPUT)
  end

  it "initializes from string correctly" do
    assert @plan
    assert_equal :empty, @plan[0,0].value
    assert_equal true, @plan[1,1].empty?
  end

  it "return neighbours" do
    assert_includes @plan[1,1].neighbours, @plan[0,0]
    assert_equal 3, @plan[0,0].neighbours.count
  end

  it "can change plan values" do
    @plan[0,0] = :occupied
    assert_equal :occupied, @plan[0,0].value
    @plan[0,0] = :empty
    assert_equal :empty, @plan[0,0].value
  end

  it "seats_people" do
    assert_equal 0, @plan.count(:occupied)
    new_state = @plan.seat_people
    assert_equal 71, new_state.count(:occupied)
    new_state = new_state.seat_people
    assert_equal 20, new_state.count(:occupied)
    new_state = new_state.seat_people
    assert_equal 51, new_state.count(:occupied)
  end

  it "counts_visible_occupied_fields" do
    input =  <<~EOL
      .......#.
      ...#.....
      .#.......
      .........
      ..#L....#
      ....#....
      .........
      #........
      ...#.....
    EOL
    plan = SeatingPlan.new_from_string(input)
    assert_equal 8, plan[3,4].occupied_visible_seats

    input =  <<~EOL
      .............
      .L.L.#.#.#.#.
      .............
    EOL
    plan = SeatingPlan.new_from_string(input)
    assert_equal 0, plan[1,1].occupied_visible_seats
    assert_equal 1, plan[3,1].occupied_visible_seats
  end

  it "stabilizes count" do
    old_state = @plan
    new_state = nil
    loop do
      new_state = old_state.seat_people
      break if new_state.count(:occupied) == old_state.count(:occupied)
      old_state = new_state
    end
    assert_equal 37, new_state.count(:occupied)
  end

  it "follos rules for part 2" do
    step_0 = <<~EOS
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
    EOS

    step_2 = <<~EOS
      #.LL.LL.L#
      #LLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLL#
      #.LLLLLL.L
      #.LLLLL.L#
    EOS
  end

  it "stabilizes part 2 count" do
    old_state = @plan
    new_state = nil
    loop do
      new_state = old_state.seat_people_two
      new_state.print
      break if new_state.fields.flatten.map(&:value) == old_state.fields.flatten.map(&:value)
      old_state = new_state
    end
    assert_equal 26, new_state.count(:occupied)
  end
end


puts "Solution 1"

old_state = SeatingPlan.new_from_string(File.read("11.dat"))
new_state = nil
loop do
  new_state = old_state.seat_people
  puts new_state.count(:occupied)
  break if new_state.count(:occupied) == old_state.count(:occupied)
  old_state = new_state
end

puts new_state.count(:occupied)

puts "Solution 2"

old_state = SeatingPlan.new_from_string(File.read("11.dat"))
new_state = nil
loop do
  new_state = old_state.seat_people_two
  puts new_state.count(:occupied)
  break if new_state.count(:occupied) == old_state.count(:occupied)
  old_state = new_state
end

puts new_state.count(:occupied)
