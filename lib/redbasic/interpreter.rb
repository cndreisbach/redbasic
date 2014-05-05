require 'redbasic/parser'
require 'redbasic/transformer'

class Redbasic::Interpreter
  attr_reader :env, :program, :current_line, :state, :next_line, :data

  def initialize
    @parser = Redbasic::Parser.new
    @transformer = Redbasic::Transformer.new
    @state = :stopped
    @current_line = nil
    @next_line = nil
    reset!
  end

  def reset!
    @env = {}
    @program = {}
    @data = []
  end

  def load(filename)
    File.open(filename).each_line do |line|
      beval_line(line.chomp)
    end
  end

  def list
    program.keys.sort.each do |line|
      puts "#{line} #{program[line].to_basic}"
    end
  end

  def run
    linenos = program.keys.sort

    @data = get_data    
    @state = :running
    @current_line = nil
    @next_line = find_next_line(linenos)

    while running? && !@next_line.nil?
      @current_line = linenos.find { |lineno| lineno >= next_line }
      @next_line = find_next_line(linenos)
      program[current_line].beval(self)
    end
    
    @state = :stopped
  end

  def [](key)
    @env[key]
  end

  def []=(key, value)
    @env[key] = value
  end

  def next_line=(line)
    @next_line = line
  end

  def find_next_line(linenos)
    return linenos.first if current_line.nil?
    linenos.find { |lineno| lineno > current_line }
  end

  def running?
    @state == :running
  end

  def stop!
    @state = :stopped
  end

  def get_data
    data = []

    program.sort.map { |line, command| 
      command 
    }.select { |command|
      command.is_a?(Redbasic::Data)
    }.each { |command|
      data.concat(command.values)
    }

    data
  end

  def ast_line(line)
    @transformer.apply(@parser.parse(line))
  end

  def beval_line(line)
    ast = ast_line(line) 
    ast.beval(self)
    self
  end
end