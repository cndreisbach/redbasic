require 'parslet'

module Redbasic
  class Parser < Parslet::Parser
    def stri(str)
      key_chars = str.split(//)
      key_chars
      .map! { |char| match["#{char.upcase}#{char.downcase}"] }
      .reduce(:>>)
    end

    def keyword(str)
      stri(str) >> space?
    end

    def list(rule)
      (rule >> str(',') >> space?).repeat >> rule
    end

    root(:statement)

    rule(:statement) do
      (lineno.maybe >> command).as(:statement)
    end

    rule(:command) do
      (let | read | data | print | goto | ifthen | forloop | fornext | terminate).as(:command)
    end

    rule(:let) do
      (keyword('LET') >> varname.as(:var) >> str('=') >> space? >> expr.as(:value)).as(:let)
    end

    rule(:read) do
      (keyword('READ') >> list(varname)).as(:read)
    end

    rule(:data) do
      (keyword('DATA') >> list(number)).as(:data)
    end

    rule(:print) do
      (keyword('PRINT') >> list((expr | string))).as(:print)
    end

    rule(:goto) do
      (keyword('GOTO') >> lineno).as(:goto)
    end

    rule(:ifthen) do
      (keyword('IF') >> comparison >> keyword('THEN') >> lineno).as(:if)
    end

    rule(:forloop) do
      (keyword('FOR') >> varname.as(:var) >> str('=') >> space? >>
      expr.as(:from) >> keyword('TO') >> expr.as(:to) >>
      (keyword('STEP') >> expr.as(:step)).maybe).as(:for)
    end

    rule(:fornext) do
      (keyword('NEXT') >> varname.as(:var)).as(:next)
    end

    rule(:terminate) { keyword('END').as(:terminate) }

    rule(:expr) { (additive | parenthetic).as(:expr) }

    rule(:parenthetic) do
      str('(') >> space? >> expr >> space? >> str(')')
    end

    rule(:additive) do
      multitive.as(:left) >> space? >> match('[+-]').as(:op) >> space? >> additive.as(:right) |
      multitive
    end

    rule(:multitive) do
      exponentive.as(:left) >> space? >> match('[*/]').as(:op) >> space? >> multitive.as(:right) |
      exponentive
    end

    rule(:exponentive) do
      primary.as(:left) >> space? >> str('^').as(:op) >> space? >> multitive.as(:right) |
      primary
    end

    rule(:primary) { parenthetic | number | varname }

    rule(:number) do
      ((str('-').maybe >>
        ((digit.repeat(0) >> str('.') >> digit.repeat(1)) |
          digit.repeat(1))).as(:digits) >>
      factor.maybe).as(:number) >> space?
    end

    rule(:factor) do
      stri('E') >> (str('-').maybe >> digit.repeat(1)).as(:factor)
    end

    rule(:string) do
      str('"') >> (
        str('\\') >> any |
        str('"').absent? >> any
      ).repeat.as(:string) >> str('"') >> space?
    end

    rule(:relation) do
      (str('=') | str('<>') | str('<') | str('<=') | str('>') | str('>=')).as(:relation) >> space?
    end

    rule(:comparison) do
      (expr.as(:left) >> relation >> expr.as(:right)).as(:comparison)
    end

    rule(:varname) { (match('[A-Za-z]') >> match('[0-9]').maybe).as(:varname) >> space? }
    rule(:lineno) { digit.repeat(1).as(:lineno) >> space? }
    rule(:digit)  { match('[0-9]') }
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
  end
end
