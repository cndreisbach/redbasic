module Redbasic
  class Error < RuntimeError
    def initialize(message, int_or_line = nil)
      @message = message
      if int_or_line.respond_to?(:current_line)
        @lineno = int_or_line.current_line
      else
        @lineno = int_or_line
      end
    end

    def message
      if @lineno
        "#{@message} on #{@lineno}"
      else
        @message
      end
    end
  end

  ProgLine = Struct.new(:line, :command) do
    def to_basic
      "#{line} #{command.to_basic}"
    end

    def beval(int)
      int.program[line] = command
    end
  end

  Var = Struct.new(:varname) do
    def to_basic
      varname.to_s
    end

    def beval(int)
      int[varname.to_sym]
    end
  end

  Number = Struct.new(:number) do
    def to_basic
      number.to_s.upcase
    end

    def beval(_)
      number
    end
  end

  String = Struct.new(:string) do
    def to_basic
      string.inspect
    end

    def beval(_)
      string
    end
  end

  Operation = Struct.new(:op, :left, :right) do
    def to_basic
      "(#{left.to_basic} #{op} #{right.to_basic})"
    end

    def beval(int)
      l = left.beval(int)
      r = right.beval(int)
      unless l.is_a?(Numeric) && r.is_a?(Numeric)
        fail Error.new('Both arguments to an operation must be numbers', int)
      end
      case op
      when '+' then l + r
      when '-' then l - r
      when '*' then l * r
      when '/' then l / r
      when '^' then l**r
      end
    end
  end

  Relation = Struct.new(:relation, :left, :right) do
    def to_basic
      "#{left.to_basic} #{relation} #{right.to_basic}"
    end

    def beval(int)
      l = left.beval(int)
      r = right.beval(int)
      case relation
      when '>'  then l > r
      when '>=' then l >= r
      when '<'  then l < r
      when '<=' then l <= r
      when '='  then l == r
      when '<>' then l != r
      end
    end
  end

  If = Struct.new(:relation, :line) do
    def to_basic
      "IF #{relation.to_basic} THEN #{line}"
    end

    def beval(int)
      int.next_line = line if relation.beval(int)
    end
  end

  Let = Struct.new(:var, :value) do
    def to_basic
      "LET #{var.to_basic} = #{value.to_basic}"
    end

    def beval(int)
      int[var.varname.to_sym] = value.beval(int)
    end
  end

  Read = Struct.new(:vars) do
    def to_basic
      "READ #{vars.map(&:to_basic).join(', ')}"
    end

    def beval(int)
      # TODO error if you cannot read
      vars.each do |var|
        datum = int.data.shift
        if datum.nil?
          fail Error.new('Out of data', int)
        else
          int[var.varname.to_sym] = datum.beval(int)
        end
      end
    end
  end

  Data = Struct.new(:values) do
    def to_basic
      "DATA #{values.map(&:to_basic).join(', ')}"
    end

    def beval(int); end
  end

  Print = Struct.new(:exprs) do
    def to_basic
      "PRINT #{exprs.map(&:to_basic).join(', ')}"
    end

    def beval(int)
      # TODO: use real print specification
      output = exprs.map { |expr| expr.beval(int).to_s }.join('   ')
      puts output
    end
  end

  Goto = Struct.new(:line) do
    def to_basic
      "GOTO #{line}"
    end

    def beval(int)
      int.next_line = line
    end
  end

  ForLoop = Struct.new(:var, :from, :to, :step) do
    def to_basic
      output = "FOR #{var.to_basic} = #{from.to_basic} TO #{to.to_basic}"
      output += " STEP #{step.to_basic}"
      output
    end

    def beval(int)
      varname = var.varname.to_sym
      bstep = step.beval(int)
      direction = bstep >= 0 ? :forward : :backward
      past_to = lambda do |num|
        (direction == :forward && num > to.beval(int)) ||
        (direction == :backward && num < to.beval(int))
      end

      current_for_loop = int.forloops.last
      if current_for_loop && current_for_loop.first == varname
        int[varname] += bstep
      else
        int.forloops.push([varname, int.current_line])
        int[varname] = from.beval(int)
      end

      if past_to[int[varname]]
        next_lineno = int.find_matching_fornext(var)
        int.forloops.pop
        if next_lineno
          int.next_line = int.find_next_line(nil, next_lineno)
        else
          fail Error.new('FOR without matching NEXT', int)
        end
      end
    end
  end

  ForNext = Struct.new(:var) do
    def to_basic
      "NEXT #{var.to_basic}"
    end

    def beval(int)
      varname = var.varname.to_sym
      for_varname, for_line = int.forloops.last
      unless varname == for_varname
        fail Error.new('NEXT without matching FOR', int)
      end
      int.next_line = for_line
    end
  end

  class Terminate
    def to_basic
      'END'
    end

    def beval(int)
      int.stop!
    end
  end
end
