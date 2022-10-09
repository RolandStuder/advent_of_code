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
      has_double_chars_repetition? && has_repeating_letter_with_one_in_between?
    end

    def has_double_chars_repetition?
      (0..(size-3)).each do |index|
        if self[(index + 2)..].include?(self[index, 2])
          return true
        end
      end

      false
    end

    def has_repeating_letter_with_one_in_between?
      (0..(size-2)).each do |index|
        if self[index] == self[index+2]
          return true
        end
      end

      false
    end
  end
end


class Day5Test < Minitest::Test
  using VeryNaughtyString

  def test_example_input
    # assert "aaxaa".has_mirror_chars?
    assert "xyxy".has_double_chars_repetition?
    assert "xyahsdfljxy".has_double_chars_repetition?
    assert "aaxaa".nice?

    assert "qjhvhtzxzqqjkmpb".nice?
    assert "xxyxx".nice?
    assert !"uurcxstgmygtbstg".nice?
    assert !"ieodomkazucvgmuy".nice?
  end
end

# using NaughtyString
using VeryNaughtyString
pp ParsingHelper.load(2015,5).lines.count(&:nice?)
