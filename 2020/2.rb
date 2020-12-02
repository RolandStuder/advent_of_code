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

class Password
  attr_reader :policy, :string
  def initialize(policy_string, password)
    @string= password
    @policy = Policy.from_string(policy_string)
  end

  def valid?
    policy.valid?(string)
  end

  def self.from_string(string)
    policy, string = string.split(": ")
    Password.new(policy, string)
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
  def test_invalid_string
    password = Password.from_string("1-3 b: cdefg")
    assert_equal false, password.valid?
  end
end

password_strings = File.readlines("2.dat")

output_one = password_strings.count do |string|
  Password.from_string(string).valid?
end

puts "ONE:"
puts output_one

