# typed: false
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/lexer'

class LexterTest < Minitest::Test
  include MonkeyLang::Token::Type

  def test_next_token_simple
    input = <<~MONKEYLANG
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
        x + y;
      }
      let result = add(five, ten);
      !-/*5
      5 < 10 > 5;
    MONKEYLANG

    expected_tokens = [
      token('let', LET),
      token('five', IDENTIFIER),
      token('=', ASSIGN),
      token('5', INTEGER),
      token(';', SEMICOLON),
      token('let', LET),
      token('ten', IDENTIFIER),
      token('=', ASSIGN),
      token('10', INTEGER),
      token(';', SEMICOLON),
      token('let', LET),
      token('add', IDENTIFIER),
      token('=', ASSIGN),
      token('fn', FUNCTION),
      token('(', LEFT_PARENTHESES),
      token('x', IDENTIFIER),
      token(',', COMMA),
      token('y', IDENTIFIER),
      token(')', RIGHT_PARENTHESES),
      token('{', LEFT_BRACE),
      token('x', IDENTIFIER),
      token('+', PLUS),
      token('y', IDENTIFIER),
      token(';', SEMICOLON),
      token('}', RIGHT_BRACE),
      token('let', LET),
      token('result', IDENTIFIER),
      token('=', ASSIGN),
      token('add', IDENTIFIER),
      token('(', LEFT_PARENTHESES),
      token('five', IDENTIFIER),
      token(',', COMMA),
      token('ten', IDENTIFIER),
      token(')', RIGHT_PARENTHESES),
      token(';', SEMICOLON),
      token('!', BANG),
      token('-', MINUS),
      token('/', FORWARD_SLASH),
      token('*', ASTERISK),
      token('5', INTEGER),
      token('5', INTEGER),
      token('<', LESS_THAN),
      token('10', INTEGER),
      token('>', GREATER_THAN),
      token('5', INTEGER),
      token(';', SEMICOLON),
      token('', EOF)
    ]

    lexer = MonkeyLang::Lexer.new(input)
    expected_tokens.each do |expected_token|
      token = lexer.next_token
      assert_equal expected_token.type, token.type
      assert_equal expected_token.literal, token.literal
    end
  end

  private def token(literal, type)
    MonkeyLang::Token.new(literal: literal, type: type, line_number: 0, column: 0)
  end
end
