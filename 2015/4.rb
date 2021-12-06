# ruby -Ilib:test 2015/4.rb
require "minitest/autorun"
require "./lib/parsing_helper"

require 'digest'

class AdventCoin
  def initialize(key)
    @key = key
  end

  def find_integer(digits = 5)
    (1..).each do |integer|
      return integer if Digest::MD5.hexdigest("#{@key}#{integer}").start_with?("0"*digits)
    end
  end
end

class Day2Test < Minitest::Test
  def test_example_input
    assert_equal 609043, AdventCoin.new("abcdef").find_integer
  end
end

pp AdventCoin.new("yzbqklnj").find_integer
pp AdventCoin.new("yzbqklnj").find_integer(6)