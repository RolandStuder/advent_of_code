class Summands
  def initialize(numbers)
    @entries = numbers
  end

  def sum_possible?(target, summands=2)
    @entries.combination(summands).find { |elements| elements.sum == target}
  end
end
