# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/lexer'

Type = MonkeyLang::TokenType

class LexterTest < Minitest::Test
  def test_next_token_simple
    input = <<~MONKEYLANG
      # This is a comment
      let five = 5; # some more comments
      let ten = 10;
      let add = fn(x, y) {
        x + y;
      }
      let result = add(five, ten);
      !-/*5
      5 < 10 > 5;
    MONKEYLANG

    expected_tokens = [
      token('let', Type::Let),
      token('five', Type::Identifier),
      token('=', Type::Equal),
      token('5', Type::Number),
      token(';', Type::SemiColon),
      token('let', Type::Let),
      token('ten', Type::Identifier),
      token('=', Type::Equal),
      token('10', Type::Number),
      token(';', Type::SemiColon),
      token('let', Type::Let),
      token('add', Type::Identifier),
      token('=', Type::Equal),
      token('fn', Type::Function),
      token('(', Type::LeftParanthesis),
      token('x', Type::Identifier),
      token(',', Type::Comma),
      token('y', Type::Identifier),
      token(')', Type::RightParanthesis),
      token('{', Type::LeftCurlyBrace),
      token('x', Type::Identifier),
      token('+', Type::Plus),
      token('y', Type::Identifier),
      token(';', Type::SemiColon),
      token('}', Type::RightCurlyBrace),
      token('let', Type::Let),
      token('result', Type::Identifier),
      token('=', Type::Equal),
      token('add', Type::Identifier),
      token('(', Type::LeftParanthesis),
      token('five', Type::Identifier),
      token(',', Type::Comma),
      token('ten', Type::Identifier),
      token(')', Type::RightParanthesis),
      token(';', Type::SemiColon),
      token('!', Type::Bang),
      token('-', Type::Minus),
      token('/', Type::ForwardSlash),
      token('*', Type::Asterisk),
      token('5', Type::Number),
      token('5', Type::Number),
      token('<', Type::LessThan),
      token('10', Type::Number),
      token('>', Type::GreaterThan),
      token('5', Type::Number),
      token(';', Type::SemiColon),
      token('', Type::EOF)
    ]

    lexer = MonkeyLang::Lexer.new(input)
    expected_tokens.each do |expected_token|
      token = lexer.next_token
      assert_equal expected_token.type, token.type
      assert_equal expected_token.literal, token.literal
    end
  end

  def test_prefix_keyword_does_not_match
    input = <<~MONKEYLANG
      fnorand
      nor
      nand
    MONKEYLANG
    expected_tokens = [
      token('fnorand', Type::Identifier),
      token('nor', Type::Identifier),
      token('nand', Type::Identifier)
    ]
    lexer = MonkeyLang::Lexer.new(input)
    expected_tokens.each do |expected_token|
      token = lexer.next_token
      assert_equal expected_token.type, token.type
      assert_equal expected_token.literal, token.literal
    end
  end

  def test_string_simple
    input = <<~MONKEYLANG
      # multiple strings
      "hello world" "hi"
      # multiline strings
      "hello there
      who are you"
      # unclosed
      "hi
    MONKEYLANG
    expected_tokens = [
      token('hello world', Type::String),
      token('hi', Type::String),
      token("hello there\nwho are you", Type::String),
      token('', Type::EOF)
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
