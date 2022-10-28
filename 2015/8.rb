# ruby -Ilib:test 2015/5.rb
require "minitest/autorun"
require_relative '../lib/grid'
require "./lib/parsing_helper"

# TODO: the inner_part / handling of the outer `"` is quite ugly, the issue is that there is an assumption that the investigated string features the quotation marks at the end and the beginning
class String
  def pure_size
    self.chomp.size
  end

  def inner_part
    return @inner_part if @inner_part
    @inner_part = self.chomp
    @inner_part = @inner_part[1..] if @inner_part.start_with?("\"")
    @inner_part.chop! if @inner_part.end_with?("\"")
    @inner_part
  end

  def unescaped_size
    index = 0
    @unescaped_size = 0
    while index < inner_part.size
      case inner_part[index..]
      when /^\\\\/
        index += 2
      when /^\\\"/
        index += 2
      when /^\\x/
        index += 4
      else
        index += 1
      end
      @unescaped_size += 1
    end
    @unescaped_size
  end

  def encode_it
    @encoded_string = "\""
    index = 0
    while index < pure_size

      case self[index..]
      when /^\\\"/
        index += 2
        @encoded_string << "\\\\\\\""
      when /^\\\\/
        index += 2
        @encoded_string << "\\\\\\\\"
      when /^\"/
        index += 1
        @encoded_string << "\\\""
      when /^\\x/
        @encoded_string << "\\\\x"
        @encoded_string << self[index+2,2]
        index += 4
      else
        @encoded_string << self[index]
        index += 1
      end
    end
    @encoded_string << "\""
  end
end


class Day8Test < Minitest::Test
  def test_part_1
    assert_equal 2, "\\\\\\\\".unescaped_size
    assert_equal 2, "\"\"\n".pure_size
    assert_equal 0, "\"\"".unescaped_size
    assert_equal 1, '\\'.unescaped_size
    assert_equal 1, "\"\\x24\"".unescaped_size
    assert_equal 10,  "\"aaa\\\"aaa\"".pure_size
    assert_equal 0,  "\"".unescaped_size
    assert_equal 1,  "\"a".unescaped_size
    assert_equal 3,  "\"aaa\"".unescaped_size
    assert_equal 7,  "\"aaa\\\"aaa\"".unescaped_size
  end

  def test_part_2
    # assert true
    assert_equal "\"\\\\\\\\\"",  "\\\\".encode_it
    assert_equal "\"\\\"\\\"\"", "\"\"".encode_it
    assert_equal  6, "\"\"".encode_it.size
    assert_equal "\"\\\"\\\\x27\\\"\"", "\"\\x27\"".encode_it
    assert_equal  11, "\"\\x27\"".encode_it.size
    assert_equal "\"\\\"aaa\\\\\\\"aaa\\\"\"",  "\"aaa\\\"aaa\"".encode_it
    assert_equal 16,  "\"aaa\\\"aaa\"".encode_it.size
  end
end


chars_in_string_code = ParsingHelper.load(2015,8).lines.sum(&:pure_size)
effective_chars = ParsingHelper.load(2015,8).lines.sum(&:unescaped_size)


puts "PART 1:"
puts chars_in_string_code - effective_chars

chars_in_string_code = ParsingHelper.load(2015,8).lines.sum(&:pure_size)
encoded_chars_size = ParsingHelper.load(2015,8).lines.map(&:encode_it).sum(&:size)

puts "PART 2:"
puts encoded_chars_size - chars_in_string_code
