# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

require_relative 'token'
module MonkeyLang
  KEYWORDS = T.let({
    'fn' => Token::Type::Function,
    'let' => Token::Type::Let,
    'true' => Token::Type::True,
    'false' => Token::Type::False,
    'if' => Token::Type::If,
    'else' => Token::Type::Else,
    'return' => Token::Type::Return
  }.freeze, T::Hash[String, Token::Type])
end
