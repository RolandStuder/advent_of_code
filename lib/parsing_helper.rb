class ParsingHelper
  attr_reader :raw

  def self.load(year, day)
    raw = File.open("#{year}/#{day}.data").readlines.join
    new(raw)
  end

  def initialize(input)
    @raw = input
  end

  def lines
    @raw.split("\n")
  end

  def integers
    lines.map { |line| line.split(/\D+/).map(&:to_i) }
  end
end
