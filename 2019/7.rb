require 'pry'
require 'minitest'
require "minitest/autorun"

require_relative "lib/int_code.rb"
require_relative "7_test.rb"

class AmplifierSequence
  def initialize(programm)
    @programm = programm
    @amplifier_controller = IntCode.new(programm)
  end

  def max_phase_setting_sequence
    max_thrust = 0
    max_sequence = nil
    all_permutations.each do |phase_setting_sequence|
      thrust = thruster_signal(phase_setting_sequence)
      if thrust > max_thrust
        max_thrust = thrust
        max_sequence = phase_setting_sequence
      end
    end
    max_sequence
  end

  def max_thruster_signal
    thruster_signal(max_phase_setting_sequence)
  end

  def thruster_signal(phase_setting_sequence, thruster_output = 0)
    phase_setting_sequence.each do |input|
      @amplifier_controller.reset
      @amplifier_controller.input = [input, thruster_output]
      thruster_output = @amplifier_controller.output.last.dup
    end
    @amplifier_controller.output.last
  end

  private

  def all_permutations
    (12345..54321).select{|perm| (perm.digits.uniq - [0,6,7,8,9]).length == 5}.map{|number| number.digits.map{|d| d-1}}
  end
end

# DOES NOT YET WORK AT ALL
class AmplifierLoop
  def initialize(programm)
    @programm = programm
    @amplifier_controllers = {}
  end

  def thruster_signal(phase_setting_sequence, thruster_input = 0)
    phase_setting_sequence.each do |phase|
      if @amplifier_controllers[phase]
        @amplifier_controllers[phase].input = [thruster_input]
      else
        @amplifier_controllers[phase] = IntCode.new(@programm,[phase, thruster_input])
      end
      output = @amplifier_controllers[phase].output.last
      thruster_input = output
    end
    thruster_input
  end

  def terminal_thrust(phase_setting_sequence)
    current_thrust = 0
    @amplifier_controllers = {}
    iteration = 0
    loop do
      new_thrust = thruster_signal(phase_setting_sequence, current_thrust)
      break if current_thrust >= new_thrust
      current_thrust = new_thrust
    end
    current_thrust
  end

  def max_phase_setting_sequence
    max_sequence = []
    max_thrust = 0
    all_permutations.map do |perm|
      new_thrust = terminal_thrust(perm)
      if new_thrust > max_thrust
        max_sequence = perm
        max_thrust = new_thrust
      end
    end
    max_sequence
  end

  def max_thruster_signal
    terminal_thrust(max_phase_setting_sequence)
  end


  def all_permutations
    (56789..98765).select{|perm| (perm.digits.uniq - [0,1,2,3,4]).length == 5}.map(&:digits)
  end
end




programm = File.open("7.dat").readlines.join.split(",")
amp = AmplifierSequence.new(programm)

puts "*" * 40
puts "Part 1:"
puts amp.max_thruster_signal

loop = AmplifierLoop.new(programm)


puts "*" * 40
puts "Part 1:"
puts loop.max_thruster_signal


