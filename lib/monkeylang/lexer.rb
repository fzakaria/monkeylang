# frozen_string_literal: true

# typed: strong
require 'sorbet-runtime'

require_relative 'token'
module MonkeyLang
  # The lexer for the Monkey language.
  # The goal of a lexer is to turn a string or input stream
  # into a series of tokens.
  class Lexer
    extend T::Sig

    sig { params(contents: String).returns(T::Array[Token]) }
    def self.parse(_contents)
      []
    end
  end
end
