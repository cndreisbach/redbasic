require 'parslet'
require 'redbasic/components'

module Redbasic
  class Transformer < Parslet::Transform
    def self.keys(*keys)
      Hash[keys.zip(keys.map { |key| simple(key) })]
    end

    rule(number: { digits: simple(:digits) }) { Number.new(digits.to_f) }
    rule(number: keys(:digits, :factor)) do
      Number.new("#{digits}e#{factor}".to_f)
    end

    rule(string: simple(:string)) { String.new(string.to_s) }

    rule(varname: simple(:varname)) { Var.new(varname.to_s) }

    rule(keys(:left, :right, :op)) do
      Operation.new(op, left, right)
    end
    rule(keys(:left, :right, :relation)) do
      Relation.new(relation, left, right)
    end

    rule(expr: simple(:expr)) { expr }

    rule(if: { comparison: simple(:comparison), lineno: simple(:lineno) }) do
      If.new(comparison, lineno.to_i)
    end
    rule(let: { var: simple(:var), value: simple(:value) }) do
      Let.new(var, value)
    end
    rule(data: sequence(:values)) { Data.new(values) }
    rule(read: sequence(:vars)) { Read.new(vars) }
    rule(print: simple(:exprs)) { Print.new([exprs]) }
    rule(print: sequence(:exprs)) { Print.new(exprs) }
    rule(goto: { lineno: simple(:line) }) do
      Goto.new(line.to_i)
    end
    rule(for: keys(:var, :from, :to)) do
      ForLoop.new(var, from, to, Number.new(1))
    end
    rule(for: keys(:var, :from, :to, :step)) do
      ForLoop.new(var, from, to, step)
    end
    rule(next: keys(:var)) do
      ForNext.new(var)
    end
    rule(terminate: simple(:_)) { Terminate.new }

    rule(statement: { lineno: simple(:line), command: simple(:command) }) do
      ProgLine.new(line.to_i, command)
    end
    rule(statement: { command: simple(:command) }) do
      command
    end
  end
end
