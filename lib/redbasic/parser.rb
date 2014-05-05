require "parslet"

module Redbasic
  class Parser < Parslet::Parser
    def stri(str)
      key_chars = str.split(//)
      key_chars.
        collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
        reduce(:>>)
    end

    def keyword(str)
      stri(str) >> space?
    end

    def list(rule)
      (rule >> str(",") >> space?).repeat >> rule
    end

    root(:statement)

    rule(:statement) {
      (lineno.maybe >> command).as(:statement)
    }

    rule(:command) {
      (let | read | data | print | goto | ifthen | terminate).as(:command)
    }

    rule(:let) {
      (keyword("LET") >> varname.as(:var) >> str("=") >> space? >> expr.as(:value)).as(:let)
    }

    rule(:read) {
      (keyword("READ") >> list(varname)).as(:read)
    }

    rule(:data) {
      (keyword("DATA") >> list(value)).as(:data)
    }

    rule(:print) {
      (keyword("PRINT") >> list(expr)).as(:print)
    }

    rule(:goto) {
      (keyword("GOTO") >> lineno).as(:goto)
    }

    rule(:ifthen) {
      (keyword("IF") >> comparison >> keyword("THEN") >> lineno).as(:if)
    }

    rule(:terminate) { keyword("END").as(:terminate) }

    rule(:expr) { (additive | parenthetic | string).as(:expr) }
   
    rule(:parenthetic) {
      str("(") >> space? >> expr >> space? >> str(")")
    }
   
    rule(:additive) {
      multitive.as(:left) >> space? >> match('[+-]').as(:op) >> space? >> additive.as(:right) |
      multitive
    }
   
    rule(:multitive) {
      primary.as(:left) >> space? >> match('[*/]').as(:op) >> space? >> multitive.as(:right) |
      primary
    }
   
    rule(:primary) { parenthetic | number | varname }
    rule(:value) { number | string }

    rule(:number) {
      ((str('-').maybe >>
        ((digit.repeat(0) >> str(".") >> digit.repeat(1)) | 
          digit.repeat(1))).as(:digits) >>
      factor.maybe).as(:number) >> space?
    }

    rule(:factor) {
      stri("E") >> (str('-').maybe >> digit.repeat(1)).as(:factor)
    }

    rule(:string) {
      str('"') >> (
        str('\\') >> any |
        str('"').absent? >> any 
      ).repeat.as(:string) >> str('"') >> space?
    }

    rule(:relation) {
      (str("=") | str("<>") | str("<") | str("<=") | str(">") | str(">=")).as(:relation) >> space?
    }

    rule(:comparison) {
      (expr.as(:left) >> relation >> expr.as(:right)).as(:comparison)
    }

    rule(:varname) { (match("[A-Za-z]") >> match("[0-9]").maybe).as(:varname) >> space? }
    rule(:lineno) { digit.repeat(1).as(:lineno) >> space? }
    rule(:digit)  { match("[0-9]") }
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
  end
end