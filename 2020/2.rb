require 'pry'
require 'minitest'
require 'minitest/autorun'

# 1-3 a: abcde
# 1-3 b: cdefg
# 2-9 c: ccccccccc
# Each line gives the password policy and then the password.
# The password policy indicates the lowest and highest number of times a given letter
# must appear for the password to be valid. For example, 1-3 a means that the password
# must contain a at least 1 time and at most 3 times.


class Policy
  attr_reader :min, :max, :char
  def initialize(min, max, char)
    @min = min.to_i
    @max = max.to_i
    @char = char
  end

  def self.from_string(string)
    min, max, char = string.split(/[-\s]/)
    Policy.new(min, max, char)
  end

  def valid?(string)
    string.count(@char).between?(min, max)
  end
end

class PolicyTwo
  attr_reader :present, :absent, :char
  def initialize(position_one, position_two, char)
    @position_one = position_one.to_i
    @position_two = position_two.to_i
    @char = char
  end

  def self.from_string(string)
    position_one, position_two, char = string.split(/[-\s]/)
    self.new(position_one, position_two, char)
  end

  def valid?(string)
    one = (string.chars[@position_one-1] == @char ? 1 : 0)
    two = (string.chars[@position_two-1] == @char ? 1 : 0)
    one + two == 1
  end
end

class Password
  attr_accessor :policy, :string
  def initialize(policy_string, password)
    @string= password
    @policy = Policy.from_string(policy_string)
  end

  def valid?
    policy.valid?(string)
  end

  def self.from_string(string)
    policy_string, string = string.split(": ")
    self.new(policy_string, string)
  end

  def self.from_string_with_policy_two(string)
    policy_string, string = string.split(": ")
    pw = Password.new(policy_string, string)
    pw.policy = PolicyTwo.from_string(policy_string)
    pw
  end
end


class PolicyTests < Minitest::Test
  def test_policy_from_string
    policy = Policy.from_string("12-5 a")
    assert_equal 12, policy.min
    assert_equal 5, policy.max
    assert_equal "a", policy.char
  end
end

class PasswordTests < Minitest::Test
  def test_password_from_string
    password = Password.from_string("1-3 a: abcde")
    assert_equal 1, password.policy.min
    assert_equal "a", password.policy.char
  end

  def test_valid_string
    password = Password.from_string("1-3 a: abcde")
    assert_equal true, password.valid?
  end
  def test_policy_two
    password = Password.from_string_with_policy_two("1-3 a: abcde")
    assert_equal true, password.valid?

    password = Password.from_string_with_policy_two("1-3 b: cdefg")
    assert_equal false, password.valid?

    password = Password.from_string_with_policy_two("2-9 c: ccccccccc")
    assert_equal false, password.valid?

    password = Password.from_string_with_policy_two("10-9 c: ccccccccac")
    assert_equal true, password.valid?
  end
end

password_strings = File.readlines("2.dat")

output_one = password_strings.count do |string|
  Password.from_string(string).valid?
end

puts "ONE:"
puts output_one


output_two = password_strings.count do |string|
  Password.from_string_with_policy_two(string).valid?
end

puts "TWO:"
puts output_two

binding.pry

_, pos_1, pos_2, char, pw = f.match(/(\d*)-(\d*) (\w): (\w*)/).to_a
