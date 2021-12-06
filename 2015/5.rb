# ruby -Ilib:test 2015/5.rb
require "minitest/autorun"
require "./lib/parsing_helper"

module NaughtyString
  refine String do
    def naughty?
      return true unless count("aeiou") >= 3
      return true unless match? /(.)\1{1,}/
      return true if ["ab", "cd", "pq", "xy"].any? { |combo| include? combo}

      false
    end

    def nice?
      !naughty?
    end
  end
end

module VeryNaughtyString
  refine String do
    def naughty?
      !nice?
    end

    def nice?
      has_double_chars_repetition? && has_mirror_chars?
    end

    def has_double_chars_repetition?
      has_it = false
      chars.each.with_index { |char, index| (has_it = true; break) if self[(index + 2)..].include? (char + self[index+1].to_s) }
      has_it
    end

    def has_mirror_chars?
      mirror_chars = false
      chars.each.with_index { |char, index| (mirror_chars = true) if (char != self[index+1] && char == self[index+2].to_s) }
      mirror_chars
    end
  end
end


class Day5Test < Minitest::Test
  using VeryNaughtyString

  def test_example_input
    assert "aaxaa".has_mirror_chars?
    assert "xyxy".has_double_chars_repetition?
    assert "aaxaa".nice?
  end
end

using VeryNaughtyString 
pp ParsingHelper.load(2015,5).lines.count(&:nice?)