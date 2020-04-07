# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/visitor/printer'

class PrinterTest < Minitest::Test
  include MonkeyLang

  def test_simple_printing
    expr = BinaryExpression.new(
      UnaryExpression.new(token('-', TokenType::Minus), LiteralExpression.new('123')),
      token('*', TokenType::Asterisk),
      GroupingExpression.new(LiteralExpression.new('45.67'))
    )

    string_io = StringIO.new
    visitor = Visitor::Printer.new string_io
    expr.accept visitor
    assert_equal '(* (- 123) (group 45.67))', string_io.string
  end

  private def token(literal, type)
    MonkeyLang::Token.new(literal: literal, type: type, line_number: 0, column: 0)
  end
end
