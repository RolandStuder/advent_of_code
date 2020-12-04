require 'pry'
require 'minitest'
require 'minitest/autorun'


class Document
  def initialize(hash)
    @data = hash
  end

  def valid?
    (necessary_fields - @data.keys).empty?
  end

  def valid_fields?
    validated_fields.values.all? { |valid, _value| valid }
  end

  def invalid_fields
    validated_fields.reject {|_, v| v }
  end

  def validated_fields
    necessary_fields.each_with_object({}) do |field, obj|
      obj[field] = [send("valid_#{field}?"), send(field)]
    end
  end

  def valid_byr?
    byr && byr.length == 4 && byr.to_i.between?(1920, 2002)
  end

  def valid_iyr?
    iyr && iyr.length == 4 && iyr.to_i.between?(2010, 2020)
  end

  def valid_eyr?
    eyr && eyr.length == 4 && eyr.to_i.between?(2020, 2030)
  end

  def valid_hgt?
    return false unless hgt

    match = hgt.match(/\A(\d*)(cm|in)\Z/)
    return false unless match

    value, unit = match[1], match[2]
    case unit
    when "cm"
      return value.to_i.between?(150,193)
    when "in"
      return value.to_i.between?(59,76)
    end
    false
  end

  def valid_hcl?
    hcl && hcl.match(/\A#[0-9a-f]{6}\Z/)
  end

  def valid_ecl?
    ecl && %w[amb blu brn gry grn hzl oth].include?(ecl)
  end

  def valid_pid?
    pid && pid.match(/\A[0-9]{9}\Z/)
  end

  def necessary_fields
    %w[ byr iyr eyr hgt hcl ecl pid ]
  end

  self.new({}).necessary_fields.each do |field|
    define_method(field.to_sym) do
      @data[field]
    end
  end

  def self.from_string(string)
    entries = string.split("\n\n")
    entries.map! do |entry|
      entry.split.each_with_object({}) do |pair, obj|
        k,v = pair.split(":")
        obj[k] = v
      end
    end
    entries.map { |e| new(e)}
  end
end


EXAMPLE_INPUT = %{
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
}

class DocumentTest < Minitest::Test
  def test_getting_entries
    documents = Document.from_string(EXAMPLE_INPUT)
    assert_equal 4, documents.count
  end

  def test_validity
    documents = Document.from_string(EXAMPLE_INPUT)
    assert documents[0].valid?
    assert_equal false, documents[1].valid?
    assert documents[2].valid?
    assert_equal false, documents[3].valid?
  end
end


puts "Solution ONE:"

documents = Document.from_string(File.read("4.dat"))
puts documents.count(&:valid?)


# part 2

VALID_EXAMPLES = %{
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
}


INVALID_EXAMPLES = %{
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
}

class DocumentTwoTest < Minitest::Test
  def test_valid_entries
    documents = Document.from_string(VALID_EXAMPLES)
    assert documents.all?(&:valid_fields?)
  end

  def test_invalid_entries
    documents = Document.from_string(INVALID_EXAMPLES)
    assert documents.none?(&:valid_fields?)
  end
end



puts "Solution TWO:"

documents = Document.from_string(File.read("4.dat"))
puts documents.count(&:valid_fields?)
