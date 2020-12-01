require 'pry'
require 'minitest'
require 'colorize'
require "minitest/autorun"

class Image
  attr_reader :layers, :data, :width, :height
  # data as string
  def initialize(data, width: 0, height: 0)
    @width = width
    @height = height
    @layers = get_layers(data)
  end

  def checksum
    layer_with_fewest_0_digits.count(1) * layer_with_fewest_0_digits.count(2) 
  end

  private

  def layer_with_fewest_0_digits
    zero_counts = @layers.map do |layer|
      layer.count(0)
    end
    layer_index = zero_counts.find_index(zero_counts.min)
    @layers[layer_index]
  end

  def get_layers(data)
    data.chars.each_slice(pixels_per_layer).map do |layer_data|
      Layer.new(layer_data.join, width: @width, height: @length)
    end  
  end

  def pixels_per_layer
    @width * @height
  end

  class Layer
    attr_reader :data, :width, :height
    def initialize(data, width: 0, height: 0)
      @width = width
      @height = height
      @data = data
    end

    def count(digit)
      @data.to_s.count(digit.to_s)
    end

    def grid
      @data.chars.each_slice(width).map do |row|
        row.map(&:to_i)
      end
    end
  end
end

class Canvas
  def initialize
    @grid = []
    @offset_x = 0
    @offset_y = 0
  end

  def paint(x,y,color="white")
    x,y = normalize(x,y)
    @grid[y] ||= []
    @grid[y][x] = color
  end

  def print
    @grid.reverse.each do |row|
      print_row row
    end
    true
  end

  private

  def print_row(row)
    row = [] if row.nil?
    colorized_row = row.each.map do |color|
      color ||= "black"
      "  ".colorize(:background => color.to_sym)
    end.join
    puts colorized_row
  end

  def normalize(x,y)
    if y < 0 && y.abs > @offset_y
      delta = y.abs - @offset_y
      @grid = Array.new(delta) + @grid
      @offset_y = y.abs
    end
    if x < 0 && x.abs > @offset_x
      delta = x.abs - @offset_x
      @offset_x = x.abs
      delta_array = Array.new(delta)
      @grid.map! do |row|
        new_row = delta_array + row
      end
    end
    [x + @offset_x, y + @offset_y]
  end
end

class ImageTests < Minitest::Test
  def setup
    @data = "123456789012"
    @image = Image.new(@data, width: 3, height: 2)
  end

  def test_layer_count
    assert_equal 2, @image.layers.size
  end

  def test_layer_digit_count
    assert_equal 1, @image.layers.first.count(1)
    assert_equal 1, @image.layers.first.count(2)
    assert_equal 0, @image.layers.first.count(7)
  end

  def test_find_layer_with_least_zeros
    assert_equal @image.layers.first, @image.send(:layer_with_fewest_0_digits)
  end

  def test_checksum
    data = "000000111223"
    image = Image.new(data, width: 3, height: 2)
    assert_equal 6, image.checksum
  end

  def test_grid
    assert_equal [[1,2,3],[4,5,6]], @image.layers.first.grid
  end
end


data = File.open('8.dat').readlines.join.strip
image = Image.new(data, width: 25, height: 6)
puts image.checksum

canvas = Canvas.new
image.layers.reverse.each do |layer|
  layer.grid.reverse.each_with_index do |row,y|
    row.each_with_index do |number,x|
      if number == 0 
        canvas.paint(x,y,"black")
      elsif number == 1
        canvas.paint(x,y,"white")
      end
    end
  end
end

canvas.print