require "minitest/autorun"
require "./lib/parsing_helper"


module AOC
  class FileSystem
    MAX_DISC_SPACE = 70_000_000
    DISC_SPACE_NEEDED_FOR_UPDATE = 30_000_000

    attr_reader :current_dir

    def cd(dir_name)
      if dir_name == ".."
        @current_dir = @current_dir.parent
      elsif dir_name == "/" && !@current_dir
        @current_dir = Directory.new("/", parent: nil)
      elsif dir_name == "/"
        while @current_dir.parent
          @current_dir = @current_dir.parent
        end
      else
        dir = @current_dir.add_directory(dir_name, parent: current_dir)
        @current_dir = dir
      end
    end

    def ls(string)
      lines = string.split("\n")
      lines.each do |line|
        size, name = line.split
        @current_dir.add_file(name, size) unless size == "dir"
      end
      @current_dir.files
    end

    def missing_space_for_update
      cd("/") # bad thing, mutating the class on this read
      available_space = (MAX_DISC_SPACE - current_dir.size)
      DISC_SPACE_NEEDED_FOR_UPDATE - available_space
    end
  end

  class Directory
    attr_reader :name, :files, :parent, :directories

    def initialize(dir_name, parent:)
      @name = dir_name
      @parent = parent
      @files = []
      @directories = []
    end

    def add_file(name, size)
      @files << File.new(name, size)
    end

    def add_directory(dir_name, parent:)
      return @directories.find { |dir| dir.name == dir_name} if @directories.find { |dir| dir.name == dir_name}

      @directories << Directory.new(dir_name, parent: parent)
      @directories.last
    end

    def size
      @files.sum(&:size) + @directories.sum(&:size)
    end

    def sum_of_directory_sizes(at_most: 100_000, sum: 0)
      sum += size if size <= at_most
      @directories.each do |directory|
        sum += directory.sum_of_directory_sizes(at_most: at_most)
      end
      sum
    end

    def dir_size_to_get_to(target:, best: Float::Infinity)
      best = size if best && size < best && size >= target
      @directories.each do |directory|
        best = directory.dir_size_to_get_to(target: target, best: best)
      end
      best
    end
  end

  class File
    attr_reader :name, :size

    def initialize(name, size)
      @name = name
      @size = size.to_i
    end
  end
end

def parse(string)
  fs = AOC::FileSystem.new
  instructions = string.split("$ ")
  instructions[1..].each do |instruction|
    if instruction.start_with?("cd")
      _, dir_name = instruction.chomp.split
      fs.cd(dir_name)
    else
      fs.ls(instruction.delete_prefix("ls\n"))
    end
  end
  fs
end

class Day7Test < Minitest::Test
  TEST_INPUT = %{$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k}

  def test_data_structure
    fs = AOC::FileSystem.new
    fs.cd("/")
    assert_equal "/", fs.current_dir.name

    fs.ls("14848514 b.txt\n8504156 c.dat")
    assert_equal 2, fs.current_dir.files.count
    assert_equal "b.txt", fs.current_dir.files.first.name
    assert_equal 14848514, fs.current_dir.files.first.size

    fs.cd("a")
    assert_equal "a", fs.current_dir.name

    fs.cd("..")
    assert_equal "/", fs.current_dir.name
  end

  def test_part_example
    fs = parse(TEST_INPUT)
    assert_kind_of AOC::FileSystem, fs
    fs.cd("/")
    assert_equal 2, fs.current_dir.directories.size
    fs.cd("a")
    assert_equal 3, fs.current_dir.files.size

    fs.cd("e")
    assert_equal 584, fs.current_dir.size

    fs.cd("..")
    assert_equal 94853, fs.current_dir.size

    fs.cd("..")
    assert_equal 48381165, fs.current_dir.size

    fs.cd("/")
    assert_equal 95437, fs.current_dir.sum_of_directory_sizes
  end

end

puts "Part 1:"

fs = parse(ParsingHelper.load(2022,7).raw)
fs.cd("/")
puts fs.current_dir.sum_of_directory_sizes

puts "Part 2:"
puts fs.current_dir.dir_size_to_get_to(target: fs.missing_space_for_update, best: 100_000_000_000)

