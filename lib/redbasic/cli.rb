require 'redbasic/interpreter'
require 'highline/import'

module Redbasic
  class CLI
    def initialize
      @interpreter = Redbasic::Interpreter.new
      @program_name = nil
    end

    def handle_input(input)
      input.strip!

      case input
      when /^RUN$/i
        @interpreter.run
        puts
      when /^LIST$/i
        @interpreter.list
        puts
      when /^SCRATCH$/i
        @interpreter.reset
        puts
      when /^REMOVE\s+(\d+)$/i
        @interpreter.rm_line($1.to_i)
        puts
      when /^STATUS$/i
        puts @interpreter.state.to_s.upcase
        puts
      when /^LOAD\s+(.+)$/i
        if File.exists?($1)
          @interpreter.load($1)
          @program_name = $1
        else
          puts "NO FILE #{$1}"
        end
        puts
      when /^SAVE$/i
        if @program_name
          @interpreter.save(@program_name)
        else
          puts "NO PROGRAM NAME"
        end
        puts
      when /^SAVE\s+(.+)$/i
        begin
          @interpreter.save($1)
          @program_name = $1
        rescue
          "BAD FILENAME #{$1}"
        end
        puts
      when /^NEW$/i
        @program_name = nil
        @interpreter.reset!
        puts
      else
        begin
          @interpreter.beval_line(input)
        rescue Redbasic::Error => ex
          puts ex.message
          puts
        end
      end
    end
  end
end
