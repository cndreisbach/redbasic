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

    def beval(int)
      number
    end
  end

  String = Struct.new(:string) do
    def to_basic
      string.inspect
    end

    def beval(int)
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
      if !(l.is_a?(Numeric) && r.is_a?(Numeric))
        raise Error.new("Both arguments to an operation must be numbers", int)
      end
      case op
      when "+" then l + r
      when "-" then l - r
      when "*" then l * r
      when "/" then l / r
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
      when ">"  then l > r
      when ">=" then l >= r
      when "<"  then l < r
      when "<=" then l <= r
      when "="  then l == r
      when "<>" then l != r
      end
    end
  end

  If = Struct.new(:relation, :line) do
    def to_basic
      "IF #{relation.to_basic} THEN #{line}"
    end

    def beval(int)
      if relation.beval(int)
        int.next_line = line
      end
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
      "READ #{vars.map(&:to_basic).join(", ")}"
    end

    def beval(int)
      # TODO error if you cannot read
      vars.each do |var|
        datum = int.data.shift
        if datum.nil?
          raise Error.new("Out of data", int)
        else
          int[var.varname.to_sym] = datum.beval(int)
        end
      end
    end
  end

  Data = Struct.new(:values) do
    def to_basic
      "DATA #{values.map(&:to_basic).join(", ")}"
    end

    def beval(int); end
  end

  Print = Struct.new(:exprs) do
    def to_basic
      "PRINT #{exprs.map(&:to_basic).join(", ")}"
    end

    def beval(int)
      # TODO use real print specification
      output = exprs.map { |expr| expr.beval(int).to_s }.join("   ")
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

  class Terminate
    def to_basic
      "END"
    end

    def beval(int)
      int.stop!
    end
  end
end