require 'pry'
require 'minitest'
require 'colorize'
require 'minitest/autorun'

require_relative 'lib/int_code'

programm = File.open('9.dat').readlines.join.split(",")
intcode = IntCode.new(programm, 1)
puts intcode.output.last


start = Time.now
programm = File.open('9.dat').readlines.join.split(",")
intcode = IntCode.new(programm, 2)
puts "Part 2"
puts intcode.output.last
puts "Computed in: #{((Time.now-start) * 1000).to_i}ms"
