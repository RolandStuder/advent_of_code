class AmplifierSequenceTests < Minitest::Test
  def test_thruster_signal
    programm = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    ideal_sequence = [4,3,2,1,0]
    max_signal = 43210

    amp = AmplifierSequence.new(programm)
    assert_equal max_signal, amp.thruster_signal(ideal_sequence)
  end

  def test_thruster_signal_2
    programm = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
    ideal_sequence = [0,1,2,3,4]
    max_signal = 54321

    amp = AmplifierSequence.new(programm)
    assert_equal max_signal, amp.thruster_signal(ideal_sequence)
    assert_equal ideal_sequence, amp.max_phase_setting_sequence
  end

  def test_thruster_signal_3
    programm = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    ideal_sequence = [1,0,4,3,2]
    max_signal = 65210

    amp = AmplifierSequence.new(programm)
    assert_equal max_signal, amp.thruster_signal(ideal_sequence)
  end

  def test_phase_setting_sequence
    programm = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    ideal_sequence = [4,3,2,1,0]
    max_signal = 43210

    amp = AmplifierSequence.new(programm)
    assert_equal ideal_sequence, amp.max_phase_setting_sequence
  end

  def test_phase_setting_sequence_2
    programm = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    ideal_sequence = [4,3,2,1,0]
    max_signal = 43210

    amp = AmplifierSequence.new(programm)
    assert_equal ideal_sequence, amp.max_phase_setting_sequence
  end

  def test_phase_setting_sequence_3
    programm = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    ideal_sequence = [1,0,4,3,2]
    max_signal = 65210

    amp = AmplifierSequence.new(programm)
    loop = AmplifierLoop.new(programm)
    assert_equal ideal_sequence, amp.max_phase_setting_sequence
    assert_equal max_signal, amp.thruster_signal(ideal_sequence)
    assert_equal max_signal, loop.thruster_signal(ideal_sequence)
  end
end

class HigherPhasesWork < Minitest::Test
  def setup
    @programm = File.open("7.dat").readlines.join.split(",")
  end

  def test_phase_3
    amplifier = IntCode.new(@programm, [3,0])
    assert amplifier.output
  end

  def test_phase_5
    amplifier = IntCode.new(@programm, [5,0])
    assert amplifier.output
  end

  def test_phase_example_programms_with_higher_phase
    programm = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    amplifier = IntCode.new(programm)
    amplifier.input = [6,0]
    assert amplifier.output
  end
end

class LoopTest < Minitest::Test
  def setup
    @programm = File.open("7.dat").readlines.join.split(",")
  end


  def test_equivalance
    programm = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    ideal_sequence = [4,3,2,1,0]
    max_signal = 43210

    amp = AmplifierSequence.new(programm)
    loop = AmplifierLoop.new(programm)
    assert_equal max_signal, amp.thruster_signal(ideal_sequence)
    assert_equal max_signal, loop.thruster_signal(ideal_sequence)
  end

  def test_terminal_thrust_one
    programm = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
    ideal_sequence = [9,8,7,6,5]
    max_signal = 139629729

    amp = AmplifierSequence.new(programm)
    loop = AmplifierLoop.new(programm)
    assert_equal loop.thruster_signal(ideal_sequence), amp.thruster_signal(ideal_sequence)
    # assert_equal max_signal, loop.terminal_thrust(ideal_sequence)
  end

  def test_terminal_thrust_two
    programm = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
    ideal_sequence = [9,7,8,5,6]
    max_signal = 18216

    amp = AmplifierSequence.new(programm)
    loop = AmplifierLoop.new(programm)
    # assert loop.thruster_signal(ideal_sequence) != 1
    # assert_equal max_signal, loop.terminal_thrust(ideal_sequence)
    assert_equal max_signal, loop.terminal_thrust(ideal_sequence)
  end
end
