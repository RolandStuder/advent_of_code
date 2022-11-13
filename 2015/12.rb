require "minitest/autorun"
require 'JSON'

class ChristmasJson
  def initialize(parsed_json_object)
    @object = parsed_json_object
  end

  def sum(object = nil)
    object ||= @object
    if object.is_a? Array
      object.map{ |elem| elem.is_a?(Integer) ? elem : sum(elem)}.compact.sum
    elsif object.is_a? Hash
      object.values.map{ |elem| elem.is_a?(Integer) ? elem : sum(elem)}.compact.sum
    end
  end

  def sum_without_reds(object = nil)
    object ||= @object
    if object.is_a? Array
      object.map{ |elem| elem.is_a?(Integer) ? elem : sum_without_reds(elem)}.compact.sum
    elsif object.is_a? Hash
      return 0 if object.values.any? { _1 == "red"}

      object.values.map{ |elem| elem.is_a?(Integer) ? elem : sum_without_reds(elem)}.compact.sum
    end
  end
end

class Day12Test < Minitest::Test
  def test_part_example
    # [1,2,3] and {"a":2,"b":4} both have a sum of 6.
    assert_equal 6, ChristmasJson.new([1,2,3]).sum
    # [[[3]]] and {"a":{"b":4},"c":-1} both have a sum of 3.
    assert_equal 3, ChristmasJson.new([[[3]]]).sum
    assert_equal 3, ChristmasJson.new({"a":{"b":4},"c":-1}).sum
    # {"a":[-1,1]} and [-1,{"a":1}] both have a sum of 0.
    assert_equal 0, ChristmasJson.new({"a":[-1,1]}).sum
    assert_equal 0, ChristmasJson.new([-1,{"a":1}]).sum

    #   [] and {} both have a sum of 0.
    assert_equal 0, ChristmasJson.new([]).sum
    assert_equal 0, ChristmasJson.new({}).sum
  end

  def test_part_example_2
    # [1,2,3] still has a sum of 6.
    assert_equal 6, ChristmasJson.new([1,2,3]).sum_without_reds
    # [1,{"c":"red","b":2},3] now has a sum of 4, because the middle object is ignored.
    assert_equal 4, ChristmasJson.new([1,{"c":"red","b":2},3]).sum_without_reds

    # {"d":"red","e":[1,2,3,4],"f":5} now has a sum of 0, because the entire structure is ignored.
    # [1,"red",5] has a sum of 6, because "red" in an array has no effect.
    #
  end
end

puts "PART: 1"
puts ChristmasJson.new(JSON.load(File.read("2015/12.json"))).sum

puts "PART: 2"
puts ChristmasJson.new(JSON.load(File.read("2015/12.json"))).sum_without_reds
