require "./lib/parsing_helper"

example = <<~EXAMPLE
            3   4
            4   3
            2   5
            1   3
            3   9
            3   3
EXAMPLE

def sum_of_distances(input)
  list_one = []
  list_two = []
  input.split("\n").each do |pair_string|
    list_one << pair_string.split.first.to_i
    list_two << pair_string.split.last.to_i
  end

  list_one.sort!
  list_two.sort!

  distances = list_one.map.with_index do |elem, index|
    (elem - list_two[index]).abs
  end
  distances.sum
end

puts sum_of_distances(example)
puts sum_of_distances(ParsingHelper.load(2024, 1).raw)
