require 'redbasic/parser'
require 'redbasic/transformer'
require 'redbasic/components'
require 'parslet'

module Redbasic
  class Interpreter
    attr_reader :env, :program, :current_line,
                :state, :next_line, :data, :forloops
    attr_writer :next_line

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
      @forloops = []
    end

    def load(filename)
      File.open(filename) do |file|
        file.each_line do |line|
          beval_line(line.chomp)
        end
      end
    end

    def save(filename)
      File.open(filename, 'w') do |file|
        list(file)
      end
    end

    def add_line(lineno, line)
      @program[lineno] = ast_line(line)
    end

    def rm_line(lineno)
      @program.delete(lineno)
    end

    def list(out = $stdout)
      program.keys.sort.each do |line|
        out.puts "#{line} #{program[line].to_basic}"
      end
    end

    def run
      linenos = program.keys.sort

      begin
        @data = find_data
        @state = :running
        @current_line = nil
        @next_line = find_next_line(linenos)

        while running? && @next_line
          @current_line = linenos.find { |lineno| lineno >= next_line }
          @next_line = find_next_line(linenos)
          program[current_line].beval(self)
        end
      rescue Redbasic::Error => ex
        puts ex.message
      ensure
        @state = :stopped
      end
    end

    def [](key)
      @env[key]
    end

    def []=(key, value)
      @env[key] = value
    end

    def find_next_line(linenos, current_line = nil)
      current_line ||= self.current_line
      linenos ||= program.keys.sort
      return linenos.first if current_line.nil?
      linenos.find { |lineno| lineno > current_line }
    end

    def find_matching_fornext(var)
      fail Error.new('FOR without matching NEXT', self) unless running?

      linenos = program.keys.sort
      lineno = @current_line

      while lineno = find_next_line(linenos, lineno)
        line = program[lineno]
        return lineno if line.is_a?(ForNext) && line.var == var
      end

      fail Error.new('FOR without matching NEXT', self)
    end

    def running?
      @state == :running
    end

    def stop!
      @state = :stopped
    end

    def find_data
      data = []

      program.sort
        .map { |_, command| command }
        .select { |command| command.is_a?(Redbasic::Data) }
        .each { |command| data.concat(command.values) }

      data
    end

    def ast_line(line)
      @transformer.apply(@parser.parse(line))
    rescue Parslet::ParseFailed
      lineno = nil
      line.match(/^\d+/) { |match| lineno = match[0] }
      raise Redbasic::Error.new('Syntax error', lineno)
    end

    def beval_line(line)
      ast = ast_line(line)
      ast.beval(self)
      self
    end
  end
end
