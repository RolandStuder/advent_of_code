require 'pry'
require 'minitest'
require 'colorize'
require 'minitest/autorun'

require_relative 'lib/int_code'
require_relative 'lib/canvas'

class Game
  attr_reader :canvas, :programm

  def initialize(programm)
    @programm = IntCode.new(programm)
    @canvas = Canvas.new

  end

  def insert_coin(amount = 1)
    @programm.memory[0] += amount
  end

  def input=(value)
    @programm.input = value
  end

  def print
    @programm.output.each_slice(3) do |x,y,id|
      @canvas.paint(x,-y, id_to_color(id))
    end
    system 'clear'
    @canvas.print
    puts score
  end

  def id_to_color(id)
    map = {
      1 => "blue",
      2 => "green",
      3 => "white",
      4 => "red"
    }
    map[id]
  end

  def ball_position
    @last_ball_position = @programm.output.each_slice(3).find{|x,y,tile| tile == 4} || @last_ball_position
  end

  def paddle_position
    @last_paddle_position = @programm.output.each_slice(3).find{|x,y,tile| tile == 3} || @last_paddle_position
  end

  def instruction
    if ball_position[0] - paddle_position[0] < 0
      -1
    elsif ball_position[0] - paddle_position[0] == 0
      0
    else
      1
    end
  end

  def auto_play
    while !@programm.terminated?
      print
      @programm.input = instruction
    end
  end

  def score
    @current_score ||= 0
    score_output = @programm.output.each_slice(3).find{ |x,y,data|  x == -1 }
    if score_output
      @current_score = score_output[2]
    end
    @current_score
  end
end

# Initial State

programm = File.open('13.dat').readlines.join.strip.split(",").map(&:to_i)
game = Game.new(programm)
game.print
puts game.canvas.grid.flatten.select{|t| t == "green"}.count

# Now to play
#
game = Game.new(programm)
p = game.programm
game.insert_coin
game.auto_play
puts game.score
# The arcade cabinet runs Intcode software like the game the Elves sent (your puzzle input).
# It has a primitive screen capable of drawing square tiles on a grid. The software draws tiles
# to the screen with output instructions: every three output instructions specify the x position
# (distance from the left), y position (distance from the top), and tile id. The tile id is
# interpreted as follows:
#                                                                                                                                                                                                                                                                                                                                                                                                      0 is an empty tile. No game object appears in this tile.
#     1 is a wall tile. Walls are indestructible barriers.
#     2 is a block tile. Blocks can be broken by the ball.
#     3 is a horizontal paddle tile. The paddle is indestructible.
#     4 is a ball tile. The ball moves diagonally and bounces off objects.
