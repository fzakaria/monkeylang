# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/visitor/interpreter'

class Interpreter < Minitest::Test
  include MonkeyLang

  def test_simple_scoping
    input = <<~MONKEYLANG
      let a = "outer a";
      {
        let a = "inner a";
      }
      a;
    MONKEYLANG

    interpreter = Visitor::Interpreter.new
    result = interpret(interpreter, input)

    assert_equal 'outer a', result
  end

  private def interpret(interpreter, script)
    lexer = Lexer.new(script)
    parser = MonkeyLang::Parser.new(lexer.each_token.to_a)
    exprs = parser.parse
    interpreter.interpret(exprs)
  end

  private def token(literal, type)
    MonkeyLang::Token.new(literal: literal, type: type, line_number: 0, column: 0)
  end
end
