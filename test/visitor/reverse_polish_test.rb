# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/visitor/reverse_polish'

class ReversePolishTest < Minitest::Test
  include MonkeyLang

  def test_simple_printing
    expr = BinaryExpression.new(
      GroupingExpression.new(
        BinaryExpression.new(
          LiteralExpression.new('1'),
          token('+', TokenType::Plus),
          LiteralExpression.new('2')
        )
      ),
      token('*', TokenType::Asterisk),
      GroupingExpression.new(
        BinaryExpression.new(
          LiteralExpression.new('4'),
          token('-', TokenType::Minus),
          LiteralExpression.new('3')
        )
      )
    )

    string_io = StringIO.new
    visitor = Visitor::ReversePolishPrinter.new string_io
    expr.accept visitor
    assert_equal '1 2 + 4 3 - *', string_io.string
  end

  private def token(literal, type)
    MonkeyLang::Token.new(literal: literal, type: type, line_number: 0, column: 0)
  end
end
