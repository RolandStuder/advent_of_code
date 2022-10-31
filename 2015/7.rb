# ruby -Ilib:test 2015/7.rb
require "minitest/autorun"
require_relative '../lib/grid'
require "./lib/parsing_helper"

class Circuit
  attr_reader :wires

  def self.from_lines(lines)
    instance = new
    lines.each do |line|
      wire = Wire.from_string(line)
      instance.wires[wire.target_id] = wire
    end
    instance
  end

  def initialize
    @wire_value = {}
    @wires = {}
  end

  def wire_value(id)
    return @wire_value[id] if @wire_value[id]

    puts id
    @wire_value[id] = wires[id].call(self)
  end

  def reset_values
    @wire_value = {}
  end
end

class Wire
  attr_reader :value, :other_value, :target_id

  def self.from_string(string)
    case string.chomp
    when /^([a-z0-9]+) \-> ([a-z]+)/
      InputWire.new(value: $1, target_id: $2)
    when /^([a-z0-9]+) AND ([a-z0-9]+) \-> ([a-z]+)/
      AndWire.new(value: $1, other_value: $2, target_id: $3)
    when /^([a-z0-9]+) OR ([a-z0-9]+) \-> ([a-z]+)/
      OrWire.new(value: $1, other_value: $2, target_id: $3)
    when /^([a-z0-9]+) LSHIFT ([a-z0-9]+) \-> ([a-z]+)/
      LeftShiftWire.new(value: $1, other_value: $2, target_id: $3)
    when /^([a-z0-9]+) RSHIFT ([a-z0-9]+) \-> ([a-z]+)/
      RightShiftWire.new(value: $1, other_value: $2, target_id: $3)
    when /^NOT ([a-z0-9]+) \-> ([a-z0-9]+)/
      NotWire.new(value: $1, target_id: $2)
    else
      raise "Pattern not recognized"
    end
  end

  def initialize(value: nil, other_value: nil, target_id: )
    @value = cast_to_type(value)
    @other_value = cast_to_type(other_value)
    @target_id = target_id
  end

  private

  def cast_to_type(value)
    if value.to_i.to_s == value
      value.to_i
    else
      value
    end
  end

  def circuit_value(circuit)
    if value.is_a? Integer
      value
    else
      circuit.wire_value(value)
    end
  end

  def circuit_other_value(circuit)
    if other_value.is_a? Integer
      other_value
    else
      circuit.wire_value(other_value)
    end
  end
end

class InputWire < Wire
  def call(circuit)
    circuit_value(circuit)
  end
end

class AndWire < Wire
  def call(circuit)
    circuit_value(circuit) & circuit_other_value(circuit)
  end
end

class OrWire < Wire
  def call(circuit)
    circuit_value(circuit) | circuit_other_value(circuit)
  end
end

class LeftShiftWire < Wire
  def call(circuit)
    circuit_value(circuit) << circuit_other_value(circuit)
  end
end

class RightShiftWire < Wire
  def call(circuit)
    circuit_value(circuit) >> circuit_other_value(circuit)
  end
end

class NotWire < Wire
  def call(circuit)
    2**16 + ~ circuit_value(circuit)
  end
end

class Day8Test < Minitest::Test
  def test_input_wire
    input_wire = Wire.from_string("123 -> x")
    assert_kind_of InputWire, input_wire
    assert_equal 123, input_wire.value
    assert_equal "x", input_wire.target_id
  end

  def test_input_wire_with_wire_input
    input_wire = Wire.from_string("b -> x")
    assert_kind_of InputWire, input_wire
    assert_equal "b", input_wire.value
    assert_equal "x", input_wire.target_id
  end

  def test_and_wire
    and_wire = Wire.from_string("x AND y -> d")
    assert_kind_of AndWire, and_wire
    assert_equal "x", and_wire.value
    assert_equal "y", and_wire.other_value
    assert_equal "d", and_wire.target_id
  end

  def test_example_circuit
    lines = <<~DATA
      123 -> x
      456 -> y
      x AND y -> d
      x OR y -> e
      x LSHIFT 2 -> f
      y RSHIFT 2 -> g
      NOT x -> h
      NOT y -> i
    DATA

    circuit = Circuit.from_lines(lines.split("\n"))

    # d: 72
    assert_equal 72, circuit.wire_value("d")
    # e: 507
    assert_equal 507, circuit.wire_value("e")
    # f: 492
    assert_equal 492, circuit.wire_value("f")
    # g: 114
    assert_equal 114, circuit.wire_value("g")
    # h: 65412
    assert_equal 65412, circuit.wire_value("h")
    # i: 65079
    assert_equal 65079, circuit.wire_value("i")
    # x: 123
    assert_equal 123, circuit.wire_value("x")
    # y: 456
    assert_equal 456, circuit.wire_value("y")
  end
end



circuit = Circuit.from_lines(ParsingHelper.load(2015, 7).lines)
puts "Start"
puts "PART 1:"
puts value_from_first_run = circuit.wire_value("a")

puts "PART 2:"
circuit.reset_values
circuit.wires["b"] = InputWire.new(value: value_from_first_run, target_id: "b")

puts circuit.wire_value("a")

