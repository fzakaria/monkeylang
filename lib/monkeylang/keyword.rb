# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

require_relative 'token'
module MonkeyLang
  KEYWORDS = T.let({
    'fn' => Token::Type::FUNCTION,
    'let' => Token::Type::LET,
    'true' => Token::Type::TRUE,
    'false' => Token::Type::FALSE,
    'if' => Token::Type::IF,
    'else' => Token::Type::ELSE,
    'return' => Token::Type::RETURN
  }.freeze, T::Hash[String, String])
end
