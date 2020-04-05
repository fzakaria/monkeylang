# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

require_relative 'token'
module MonkeyLang
  KEYWORDS = T.let({
    'fn' => Token::Type::FUNCTION,
    'let' => Token::Type::LET
  }.freeze, T::Hash[String, String])
end
