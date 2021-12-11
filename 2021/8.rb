# ruby -Ilib:test 2021/8.rb
require "minitest/autorun"
require_relative "lib/parsing_helper"

class Display
  def self.from_patterns(patterns)
    patterns.map! { |pattern| pattern.chars.sort.join }

    digits_to_signals = {
      1 => patterns.find { _1.size == 2 },
      4 => patterns.find { _1.size == 4 },
      7 => patterns.find { _1.size == 3 },
      8 => patterns.find { _1.size == 7 },
    }

    segment_counts = patterns.map(&:chars).flatten.tally

    a = segment_counts.find{ |segment, count| count == 8 && (!digits_to_signals[1].chars.include? segment)}.first
    segment_counts.delete(a)

    b = segment_counts.invert[6]
    segment_counts.delete(b)

    c = segment_counts.find{ |_, count| count == 8}.first
    segment_counts.delete(c)


    d = segment_counts.find{ |segment, count| count == 7 && (digits_to_signals[4].chars.include? segment)}.first
    segment_counts.delete(d)

    e = segment_counts.invert[4]
    segment_counts.delete(e)

    f = segment_counts.invert[9]
    segment_counts.delete(f)

    g = segment_counts.keys.first

    digits_to_signals[0] = [a,b,c,e,f,g].sort.join
    digits_to_signals[2] = [a,c,d,e,g].join
    digits_to_signals[3] = [a,c,d,f,g].join
    digits_to_signals[4] = [b,c,d,f].join
    digits_to_signals[5] = [a,b,d,f,g].join
    digits_to_signals[6] = [a,b,d,e,f,g].join
    digits_to_signals[9] = [a,b,c,d,f,g].join

    digits_to_signals.transform_values! { |string| string.chars.sort.join }

    Display.new(digits_to_signals.invert)
  end

  def initialize(signals_to_digits)
    @mappings = signals_to_digits
  end

  def show(digits)
    digits.map { |digit| @mappings[digit.chars.sort.join]}
  end
end


class Day8Test < Minitest::Test
  def test_example_input
    example_input = %{dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
cefg dcbef fcge gbcadfe}
    patterns, digits = example_input.split("|").map(&:split)
    assert_equal "dbcfg", patterns.first
    display = Display.from_patterns(patterns)
    assert_equal [4, nil, 4, 8].compact, (display.show(digits) - [5])
  end

  def test_full_input
    example_input = %{acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
cdfeb fcadb cdfeb cdbaf}
    patterns, digits = example_input.split("|").map(&:split)
    display = Display.from_patterns(patterns)
    assert_equal [5, 3, 5, 3], display.show(digits)
  end

  def test_full_example
    exmaple_input = %{be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce}
    solutions = [8394, 9781, 1197, 9361, 4873, 8418, 4548, 1625, 8717, 4315]
    lines = exmaple_input.split("\n")
    solutions.each_with_index  do |solution, index|
      patterns, digits = lines[index].split("|").map(&:split)
      display = Display.from_patterns(patterns)
      assert_equal solution.digits.reverse, display.show(digits), message: "fail at example solution #{solution}"
    end
  end
end

# part 1

instructions = ParsingHelper.load(8).lines.map { |line| line.split("|").map(&:split)}
pp instructions.map { |patterns, digits| (Display.from_patterns(patterns).show(digits) - [nil, 0, 2, 3, 5, 6, 9]).size }.sum
pp instructions.map { |patterns, digits| Display.from_patterns(patterns).show(digits).join.to_i }.sum

#    0:      1:      2:      3:      4:
#     aaaa    ....    aaaa    aaaa    ....
#    b    c  .    c  .    c  .    c  b    c
#    b    c  .    c  .    c  .    c  b    c
#    ....    ....    dddd    dddd    dddd
#    e    f  .    f  e    .  .    f  .    f
#    e    f  .    f  e    .  .    f  .    f
#    gggg    ....    gggg    gggg    ....
#
# EC
#    
#    5:      6:      7:      8:      9:
#     aaaa    aaaa    aaaa    aaaa    aaaa
#    b    .  b    .  .    c  b    c  b    c
#    b    .  b    .  .    c  b    c  b    c
#     dddd    dddd    ....    dddd    dddd
#    .    f  e    f  .    f  e    f  .    f
#    .    f  e    f  .    f  e    f  .    f
#     gggg    gggg    ....    gggg    gggg
#
# 2 size -> 5  (diff 4 == 3)
# 3 size -> 5  (diff 1 == 3)
# 5 size -> 5  (diff 4 == 2)
#
# 9 (built from 4 * 3)
# 6
# # 0
#
# segments a -> 8
# segments b -> 6 uniq
# segemtns c -> 8
# segmetns d -> 7
# segmengs e -> 4 uniq
# segmetns f -> 9 uniq
# segments g -> 7
