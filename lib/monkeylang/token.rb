# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative 'token_type'

# The main module for MonkeyLang
module MonkeyLang
  extend T::Sig

  # The various tokens that are possible in the Monkey language
  class Token < T::Struct
    extend T::Sig

    const :literal, String
    const :type, Type

    # Debugging information
    const :line, String
    const :line_number, Integer
    const :column, Integer

    sig { returns(String) }
    def to_s
      if type.to_s != literal
        "[#{line_number}:#{column}] #{type} #{literal}"
      else
        "[#{line_number}:#{column}] #{literal}"
      end
    end
  end
end
