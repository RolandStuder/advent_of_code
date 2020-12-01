require 'pry'
require 'minitest'
require "minitest/autorun"

# abcdef contains no letters that appear exactly two or three times.
# bababc contains two a and three b, so it counts for both.
# abbcde contains two b, but no letter appears exactly three times.
# abcccd contains three c, but no letter appears exactly two times.
# aabcdd contains two a and two d, but it only counts once.
# abcdee contains two e.
# ababab contains three a and three b, but it only counts once.
# Of these box IDs, four of them contain a letter which appears exactly twice, and three of them contain a letter which appears exactly three times. Multiplying these together produces a checksum of 4 * 3 = 12.



TEST_INPUT = "abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab".freeze

PUZZLE_INPUT = "pbopcmjeizuhxlqnwasfgtycdm
pjokrmjeizuhxlqnfasfguycdv
pbokrpjejkuhxlqnwasfgtycdv
sbokrmjeizuhxaqnwastgtycdv
pbokrmjeizuhxljnnasfgtycnv
pbokrqjeizuhxbqndasfgtycdv
bbokrmjeizuhxlqnwasfgtycfj
pbokrmjeisuhxlqnwasfzdycdv
pbokrmjefxuhxlqnwasfptycdv
pqokrmjenzuhxlqnwasfgtygdv
pbokrmjeizunklqnwassgtycdv
pbokrmjeizghxvqnkasfgtycdv
lboirmjeizuhxlqnwfsfgtycdv
pbofrmjeizuhalqnwasfgtyddv
pbokrmjeiguhplqcwasfgtycdv
pbokrmjeizzhxlqnwavfgtyctv
pbokrmjeizuhxlqnwaefgtycaj
pbokzmjedzuhxlqnwasfgtlcdv
pnokrmjegzuhxlbnwasfgtycdv
pbojrmjeizuhtlqniasfgtycdv
pbokxmiefzuhxlqnwasfgtycdv
pbokrmoeizuhxlqnpasngtycdv
abokrmjeezuhxlqnwasfdtycdv
pbokrmyeizugxlqnwasfgtycda
pbokdmjeizuhxlqnuatfgtycdv
psokrmjeiauhxlqnwasxgtycdv
pbokrmjeizuhxlqzwasfgtyzdy
pboktmjeizuhxnqndasfgtycdv
pbodrrjeizuhxlqnwasfgtycdb
pbokrmjekzuhxljnwasfgtycuv
pbokrmjnizuhllqnwawfgtycdv
prmkrmjeiwuhxlqnwasfgtycdv
pbokrmjeizkhxlenwajfgtycdv
pbofrmjeizuixlqnwasfgoycdv
gbhkrmjeizuhclqnwasfgtycdv
pbokrmweizuwxlqnwasfgtycyv
pbukrmjeizuhxlqnwasfgqhcdv
pbokxmjeizuhxlqnwasfgtecdu
pbokomjeizuhrlqnfasfgtycdv
bbokymjeizuhxlqnpasfgtycdv
pbodrmjeizuhxlqnwadfgtgcdv
zbokrljeipuhxlqnwasfgtycdv
pboermjeizuxxlqnwasfgtpcdv
pqbkrmjeizuhxlqnjasfgtycdv
pbokrmfeizuhxvqgwasfgtycdv
pbokrmjeizuhzlqnjasfdtycdv
rbofrmjeizkhxlqnwasfgtycdv
pbokrmseizubxlqnwasfgtycdy
pbocrmjeizuhxaqnwasfgtycda
pbokrmjeizuhxlqndakfgtscdv
pbokrrjeizuhxlqnwgshgtycdv
pbokrajeizuhxpqnwasrgtycdv
pbokrbjeizubxlqnwssfgtycdv
pbokemjhizuhxlqnwazfgtycdv
pbokrmjeizuhxlqntisfgtyrdv
pbokrmjwinuhxlqnwasfgkycdv
pypkrmjeizuhxlqtwasfgtycdv
pbokrmjeizuhxlqniasfrpycdv
pbokomjeizuhxlqnwasfgtgcdw
pbokrmjeizusplqnwxsfgtycdv
pbodrmueizxhxlqnwasfgtycdv
pbokwmjeizurxlqnwasfgtycdi
pbohrmjejzuhxlqnwasfgtycgv
pbokrmtqizuhxlqnwasfitycdv
ptozrmjeizuhylqnwasfgtycdv
pbokrmjtizuhxlqfwasfgtykdv
pbokrmpeizuhxnqmwasfgtycdv
pbokrmjeizujxlynwtsfgtycdv
dbokrmjeizuhxlqnwasngticdv
pbskrmjeizuhxlqnrasfttycdv
pbwkrmjerzuhxlqnwaslgtycdv
pboyrmceizuhxlqnwssfgtycdv
pbokpmjeizchxlqngasfgtycdv
pbokrmjenzuhxlqnwcsfgxycdv
pbxkrmjeizuhxlqnwadfgtyckv
pbqkrmjeizuhxlqnwasdgdycdv
pbokrmoeizdhxlqnwasfgtycqv
pbokrmjejzuhxlqnwksfgtycwv
pbfkrmjeieuhxlnnwasfgtycdv
pbokrmjeiuuhxlqnpalfgtycdv
pbokrmjeizunxyqnwasfgtdcdv
pbokrmjeazuhxrqnwasogtycdv
pbmkrmjeizuhxlqnwaufgtycdj
xbskrmjeipuhxlqnwasfgtycdv
tbokrujlizuhxlqnwasfgtycdv
xbokvmjeizuhxyqnwasfgtycdv
pbnhrmheizuhxlqnwasfgtycdv
pboorajrizuhxlqnwasfgtycdv
pbokrmjeizuhxminwusfgtycdv
pboqrmjeizuhxlqnwaslgtscdv
pgokrdjeizuhxlnnwasfgtycdv
pbokrmjeizuhxiqnwasvttycdv
pbokrmwnizuhzlqnwasfgtycdv
pbokrmjlizmhjlqnwasfgtycdv
pbwkrmjeizohxlqnwasfgtyzdv
pbykrmjmizwhxlqnmasfgtycdv
pbokrmjzizuhxeqnwasfgtpcdv
pbokrmjewzuhxzqnwasfgtybdv
pbokrmjeimupxlonwasfgtycdv
pbokrmjvizuhxlqnuasfgtycqv
pbokrmjeizjdxlqnwasfetycdv
pbofrmjeizurxlqnwasfztycdv
pbozrmjeizuhxxqpwasfgtycdv
pbovtmjeizuhxlqnwapfgtycdv
prokrmjeuzuhxlqnwasfgtycqv
ubokrmjeizuhxljnwasfgtdcdv
pboknmjepzuhxlqnwasogtycdv
pbokrmjaizuaxljnwasfgtycdv
pbdkrcjeizuhxlqnwasfgtvcdv
pbokymjeizuhxlqnwaxfgtyfdv
pbokrmjaizuhxlqnfasfgtyodv
pdekrmmeizuhxlqnwasfgtycdv
rbokrmjeizuuxlqnwasfgtycdj
pbokrmneifuhxlqiwasfgtycdv
pbokrmjeizlbxlunwasfgtycdv
pbokrmjewzuhxxqnwasfgoycdv
pbokrmjeizuhxlqtwasfgtzcdo
pbokrmkeizzhxlqnwasfgtycmv
pbokrmjeiquhxlqnywsfgtycdv
xbokrmjeizjhxlqdwasfgtycdv
pbokrmjeizahxzqnzasfgtycdv
pbokrmjeizuhxmqmwasfgtytdv
pbokrmheiluhxlqnwasfgoycdv
rbokrmjeizuhxlqnwaslgtycqv
pbbkzmjeizuhxvqnwasfgtycdv
pbokrmjeizudxlznwgsfgtycdv
pbokemjeizuhxlqnwascgtysdv
pbokrmjdizuexlgnwasfgtycdv
pbokzmjeizuhxlqnwnsfggycdv
pbokrmjeizuhxtqnwasfgiycdy
bbokrmjeizuhclunwasfgtycdv
pbtkrmjeieuhxlqnwasfgtycrv
pbokrmjeizutxlbnwasngtycdv
pbokrmjevzumxlqnwasfgtyydv
pbokrmjsizuhxlqowasfgtycyv
pbssrmjeizuhxlqbwasfgtycdv
pbokrmjeizuhflqnwxsfstycdv
pbokimjeizuhxlqnwasfgtywdm
pbokrmjbizuhxlqdwasfgtygdv
pbokrmheizuhxlqxwasfgtycnv
poakrmjeizuhylqnwasfgtycdv
vbrkrmjeizuhxlqnwaszgtycdv
pbokrmjeizuhxiqnudsfgtycdv
pbokrldeizuhxlqnwasjgtycdv
pbokrmjeizjhflqnwasfgtymdv
pbokrmjeizuhxliawasfgtvcdv
pbokrmjeisuhtoqnwasfgtycdv
nbokrijeizuhxlqnwasfgtycdh
pbokrmjeizrhxlqnwxsfztycdv
pbotrmjeizuhxlcnwasfgtyvdv
pbokrmjewzuhxlquwasfgtjcdv
pbosrmjeipuhxlqnwasfgtvcdv
pbokrmjebzurxlunwasfgtycdv
pbogimieizuhxlqnwasfgtycdv
pbokrmjeizihxlqnwasagtyzdv
pbokrmjeizuoxlqnausfgtycdv
pbokrmjeizuhxlqnwashgbjcdv
pbokrdjeizuhxlnnwasfgoycdv
pbokrzjtizlhxlqnwasfgtycdv
peokrmjexzuhxlqnwasfgoycdv
cboprmjeizuhxlqnwasfgfycdv
pbitrmjeizjhxlqnwasfgtycdv
pbourmjeizuhxldnwjsfgtycdv
pboivmjeizuhxlqnwasvgtycdv
pbokrmjeiduhxaqnqasfgtycdv
pbokicjeiwuhxlqnwasfgtycdv
pbokrmmeizulxlqnwasfgtyvdv
pbokrmjeieuhxlqnaapfgtycdv
pbokxmjeiuuhxlqnwasfgtyqdv
pbokrmjeizuhxgqniaslgtycdv
pbokrmjeizuuxlqnwisfgtyckv
pbovlmjepzuhxlqnwasfgtycdv
pbokrmjeizuhxlqdwaqfgtycdj
pbztrvjeizuhxlqnwasfgtycdv
pbokrmjeizuholunwasfptycdv
pbokrmjeizudxlqnwusfgtycqv
nbokrmjzizmhxlqnwasfgtycdv
pbokrmjeypunxlqnwasfgtycdv
pbokrjjxizuhxlqnwasfgtyddv
pbokrmjeizuhilqnwiufgtycdv
pbokrmjeizuhxtqowasfgfycdv
qbokrgjeizuhxlqnwasfgtycdx
pvoarmjeizuhxlqnwasfgtfcdv
pbokrmjjizuhxlqnwasfggyczv
pbtkrmjeizuhnlqncasfgtycdv
pbokrmjeizuzxlqnwasfgtyjnv
jmokrmzeizuhxlqnwasfgtycdv
pbykrmjmizwhxlqnwasfgtycdv
nbokrmjeizlhxlqnwasfgtecdv
pbokrmjeizuhxlqhwasrgrycdv
pbokrmjeiruhxlqnwasfgtnedv
pbokrmjeizohxlznwasfgtycuv
paokrmjdizuhxlqnwasfktycdv
pbokrmjetzutxlqnwasfntycdv
pboyrmjeizuhxlqnwasfgtetdv
pbokgujeizuhxlqwwasfgtycdv
pbokrifeizshxlqnwasfgtycdv
sbokrmjeizfhxlqnaasfgtycdv
pbokrmjeizuhxlqpwrsfgfycdv
pbokxmjeikuhxlqnwasfctycdv
fbokrmjhizuhxlqnmasfgtycdv
pbekamjeizuhxlqnwaxfgtycdv
pboksmpeizuhxlqnwasfgtyclv
pbokrmjeizrhxdqnwasfgzycdv
pbogrmxeizurxlqnwasfgtycdv
pbokrmjeieuhxlqnwqsfgtychv
vbokrmjeizuhxlqnwabfgtycdq
lbokrmjeizupxlqvwasfgtycdv
pbokrmjeizuhglqnuasfgtucdv
hbokrmjeizuhelqnwasfgtrcdv
pbokrmweizuhxlqnwhsfgtyvdv
pbokrmjeizuhxrqnwasfvtccdv
pbokrmneizuhxlwnyasfgtycdv
ybokymjeqzuhxlqnwasfgtycdv
pbousmjeizuhxlqswasfgtycdv
pblkimjeizuhxlqnwacfgtycdv
psokrmjeizuhxlqnwasfgbpcdv
peokrwjeizghxlqnwasfgtycdv
pbokrmjeizudxlqnwzsfrtycdv
pbotrmjezzxhxlqnwasfgtycdv
pkokrmjezzuhxlqnwasfgtycdh
pbokrmleizuhxlnnwasfgtyndv
pboxwmjeituhxlqnwasfgtycdv
pbokrmjeizoczlqnwasfgtycdv
pbokomjeizuhxlqnwhsfgtybdv
pbhwrmjeizuhxlqnwasfgpycdv
pbwkrmjeizuhxeqnwasfgtyidv
pbokrmjeizuhxlqnjasfgmicdv
tbokrgjeizuhxlqhwasfgtycdv
pbolrqjeizuhxlqnhasfgtycdv
pbogrhjeizbhxlqnwasfgtycdv
pbokrmjeizghxlqnwashgtycdx
pbokrmjeizuhrlqnwasfgthcrv
pbokrmjeizuhxlqnwfsngtacdv
pbokrmxeizuhxlqnwasfotyctv
pbokrmjeizuhxlqnwcsfgnocdv
pnokbmjeizuhxlqnwasfgtscdv
pbowrmjeuzuhxlqnwasfgtycdw
pbokrmjeiyuhxlqnwasqgtvcdv
pbokrmjeivuhxkpnwasfgtycdv
pbokomjeizuhxlqnwasfgtylav
pbdkrmjeizuhxlgnwjsfgtycdv
pbokrmjeizuaxxqnwasfytycdv
pbokrmjerzuhxlqnwasfgtscdk
pbokrmzerzuhxlqnwasfntycdv
pbokrmjeizumxdqnwasfgtyckv
pbtkrmjeizrhxlqnwasfgtjcdv
pbmkrmjuizuhxlqnwasfgtytdv
pbokpmjeizuhxlqnwastgtzcdv
kbokrmjeizuhxlqnwasfgzjcdv".freeze


## STEP 1 DESCRIPTION

class PuzzleTests < Minitest::Test
  def text_none
    assert_equal FrequencyMap.new("abcdef").frequency(2), 0
    assert_equal FrequencyMap.new("abcdef").frequency(3), 0
  end

  def test_2_and_3
    assert_equal FrequencyMap.new("bababc").frequency(2), 1
    assert_equal FrequencyMap.new("bababc").frequency(3), 1
  end

  def test_2
    assert_equal FrequencyMap.new("abbcde").frequency(2), 1
    assert_equal FrequencyMap.new("abbcde").frequency(3), 0
  end

  def test_double_2
    assert_equal FrequencyMap.new("aabcdd").frequency?(2), true
    assert_equal FrequencyMap.new("aabcdd").frequency?(3), false
  end

  def test_input
    assert_equal 12, Solver.new(TEST_INPUT).result
  end
end

class FrequencyMap
  def initialize(letters)
    @letters = letters
  end

  def frequency(f)
    char_counts.values.count{ |count| count == f}
  end

  def frequency?(f)
    char_counts.values.any?{ |count| count == f}
  end

  def char_counts
    return @char_counts if @char_counts
    @char_counts = @letters.chars.inject({}) do |memo, char|
      if memo[char]
        memo[char] += 1
      else
        memo[char] = 1
      end
      memo
    end
  end
end


class Solver
  attr_accessor :input

  def initialize(input)
    @input = input
  end

  def result
    frequencies = [2,3]
    counts = lines.inject({}) do |memo, line|
      map = FrequencyMap.new(line)
      frequencies.each do |f|
        if map.frequency? f
          memo[f] ? memo[f] += 1 : memo[f] = 1
        end
      end
      memo
    end
    counts[2].to_i * counts[3].to_i
  end

  def lines
    @input.split("\n")
  end

  def lines_to_i
    lines.map(&:to_i)
  end
end

puts "*" * 100
puts Solver.new(PUZZLE_INPUT).result


### STEP 2

class Solver_2 < Solver
  def result
    lines.each_with_index do |line, index|
      compare_to_rest(line, index)
    end
    binding.pry
  end

  def compare_to_rest(line, start)
    return false if start == lines.size
    (start+1..lines.size).each do |index|
      comparison_line = lines[index]
      # if difference_in_letters(line, comparison_line) == 1
      difference = difference_in_positioned_letters(line, comparison_line)
      if difference && difference.length == 1
        puts difference_in_positioned_letters(line, comparison_line) 
        puts line
        puts start
        puts comparison_line
        puts index
        break
      end
      # end
    end
  end

  def difference_in_letters(line1, line2)
    return false unless line1 && line2
    (line1.chars - line2.chars).count
  end

  def difference_in_positioned_letters(line1, line2)
    return false unless line1 && line2
    letters = ""
    line1.chars.each_with_index do |char, index|
      letters << char if char != line2.chars[index]
    end
    letters
  end

end

puts "*" * 100
puts Solver_2.new(PUZZLE_INPUT).result

binding.pry

