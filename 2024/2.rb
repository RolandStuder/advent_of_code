require "./lib/parsing_helper"
require "minitest/autorun"
require "delegate"
require 'forwardable'

input = ParsingHelper.load(2024, 2).integers

example = <<~EXAMPLE
            7 6 4 2 1
            1 2 7 8 9
            9 7 6 2 1
            1 3 2 4 5
            8 6 4 4 1
            1 3 6 7 9
EXAMPLE

class ReportSequence
  include Enumerable
  extend Forwardable

  def_delegators :@sequence, :each, :size

  def initialize(sequence)
    @sequence = sequence
  end

  def safe?
    monotonic? && delta_no_bigger_than?(3)
  end

  # not that we not considereing staying on the same number monotonic
  def monotonic?
    return true if size <= 1

    deltas.all?(&:positive?) || deltas.all?(&:negative?)
  end

  def delta_no_bigger_than?(max_delta)
    deltas.all? { |delta| delta.abs <= max_delta }
  end

  private

  def deltas
    each_cons(2).map { |a, b| b - a }
  end
end

class ReportSequenceTest < Minitest::Test
  def test_monotonic
    assert ReportSequence.new([7, 6, 4, 2, 1]).monotonic?
    refute ReportSequence.new([1, 1]).monotonic?
  end

  def test_delta_no_bigger_than_three
    assert ReportSequence.new([7, 6, 4, 2, 1]).delta_no_bigger_than?(3)
  end

  def test_safe?
    assert ReportSequence.new([7, 6, 4, 2, 1]).safe?
    refute ReportSequence.new([1, 2, 7, 8, 9]).safe?
    refute ReportSequence.new([9, 7, 6, 2, 1]).safe?
    refute ReportSequence.new([1, 3, 2, 4, 5]).safe?
    refute ReportSequence.new([8, 6, 4, 4, 1]).safe?
    assert ReportSequence.new([1, 3, 6, 7, 9]).safe?
  end
end

puts input.map { |sequence| ReportSequence.new(sequence) }.count(&:safe?)
