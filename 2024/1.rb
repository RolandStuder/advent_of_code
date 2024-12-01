require "./lib/parsing_helper"

example = <<~EXAMPLE
            3   4
            4   3
            2   5
            1   3
            3   9
            3   3
EXAMPLE

def sorted_lists(input)
  list_one = []
  list_two = []
  input.split("\n").each do |pair_string|
    list_one << pair_string.split.first.to_i
    list_two << pair_string.split.last.to_i
  end
  return list_one.sort, list_two.sort
end

def sum_of_distances(list_one, list_two)
  distances = list_one.map.with_index do |elem, index|
    (elem - list_two[index]).abs
  end
  distances.sum
end

example_list_one, example_list_two = sorted_lists(example)
list_one, list_two = sorted_lists(ParsingHelper.load(2024, 1).raw)
puts sum_of_distances(example_list_one, example_list_two)
puts sum_of_distances(list_one, list_two)
