class PuzzleInput
  attr_reader @lines
  
  def initialize(filename)
    @lines = File.open(filename).readlines.map(&:strip)
  end

  def as_integer
    @lines.map(&:to_int)
  end
end