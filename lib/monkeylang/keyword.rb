# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

require_relative 'token_type'
module MonkeyLang
  KEYWORDS = T.let({
    'fn' => TokenType::Function,
    'let' => TokenType::Let,
    'true' => TokenType::True,
    'false' => TokenType::False,
    'if' => TokenType::If,
    'else' => TokenType::Else,
    'return' => TokenType::Return,
    'super' => TokenType::Super,
    'while' => TokenType::While,
    'for' => TokenType::For,
    'nil' => TokenType::Nil,
    'class' => TokenType::Class,
    'and' => TokenType::And,
    'or' => TokenType::Or,
    # TODO: Remove once the standard library has been declared
    'print' => TokenType::Print
  }.freeze, T::Hash[String, TokenType])
end
