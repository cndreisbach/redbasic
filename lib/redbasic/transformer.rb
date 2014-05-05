require 'parslet'
require 'redbasic/components'

module Redbasic
  class Transformer < Parslet::Transform
    rule(:number => {:digits => simple(:digits)}) { Number.new(digits.to_f) }
    rule(:number => {:digits => simple(:digits), :factor => simple(:factor)}) {
      Number.new("#{digits}e#{factor}".to_f)
    }
    
    rule(:string => simple(:string)) { String.new(string.to_s) }

    rule(:varname => simple(:varname)) { Var.new(varname.to_s) }
    
    rule(:left => simple(:left), :right => simple(:right), :op => simple(:op)) { 
      Operation.new(op, left, right) 
    }
    rule(:left => simple(:left), :right => simple(:right), :relation => simple(:relation)) {
      Relation.new(relation, left, right)
    }
    
    rule(:expr => simple(:expr)) { expr }

    rule(:if => {:comparison => simple(:comparison), :lineno => simple(:lineno)}) {
      If.new(comparison, lineno.to_i)
    }
    rule(:let => {:var => simple(:var), :value => simple(:value)}) {
      Let.new(var, value)
    }
    rule(:data => sequence(:values)) { Data.new(values) }
    rule(:read => sequence(:vars)) { Read.new(vars) }
    rule(:print => simple(:exprs)) { Print.new([exprs]) }
    rule(:print => sequence(:exprs)) { Print.new(exprs) }
    rule(:goto => {:lineno => simple(:line)}) {
      Goto.new(line.to_i)
    }
    rule(:terminate => simple(:_)) { Terminate.new }

    rule(:statement => {:lineno => simple(:line), :command => simple(:command)}) {
      ProgLine.new(line.to_i, command)
    }
    rule(:statement => {:command => simple(:command)}) {
      command
    }
  end
end