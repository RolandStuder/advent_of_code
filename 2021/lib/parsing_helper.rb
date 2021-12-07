class ParsingHelper
  attr_reader :raw

  def self.load(number)
    raw = File.open("2021/#{number}.data").readlines.join
    new(raw)
  end

  def initialize(input)
    @raw = input
  end

  def lines
    @raw.split("\n")
  end

  def integers
    lines.first.split(",").map(&:to_i)
  end

end
