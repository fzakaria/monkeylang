# typed: false
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/lexer'

class LexterTest < Minitest::Test
  def test_next_token
    input = <<~MONKEYLANG
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
        x + y;
      }
      let result = add(five, ten);
    MONKEYLANG

    expected_tokens = [
      MonkeyLang::Token.new('let', MonkeyLang::Token::Type::LET, 0, 0),
      MonkeyLang::Token.new('five', MonkeyLang::Token::Type::IDENTIFIER, 0, 0)
    ]

    lexer = MonkeyLang::Lexer.new(input)
    expected_tokens.each do |expected_token|
      token = lexer.next_token
      assert_equal expected_token.literal, token.literal
      assert_equal expected_token.type, token.type
    end
  end
end
