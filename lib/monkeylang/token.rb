# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

# The main module for MonkeyLang
module MonkeyLang
  extend T::Sig

  # The various tokens that are possible in the Monkey language
  class Token < T::Struct
    extend T::Sig

    # An enumeration of all Token types in MonkeyLang
    class Type < T::Enum
      enums do
        Illegal = new('ILLEGAL')
        EOF = new

        # Identifiers & literals
        Identifier = new('IDENTIFIER') # ex. add, foobar, x, y
        Integer = new('INTEGER') # 123456

        # Operators
        Assign = new('=')
        Plus = new('+')
        Minus = new('-')
        Bang = new('!')
        Asterisk = new('*')
        ForwardSlash = new('/')
        LessThan = new('<')
        GreaterThan = new('>')

        # Delimiters
        Comma = new(',')
        SemiColon = new(';')

        LeftParanthesis = new('(')
        RightParanthesis = new(')')
        LeftCurlyBrace = new('{')
        RightCurlyBrace = new('}')

        # Keywords
        Function = new('FUNCTION')
        Let = new('LET')
        True = new('TRUE')
        False = new('FALSE')
        If = new('IF')
        Else = new('ELSE')
        Return = new('RETURN')
      end
    end

    const :literal, String
    const :type, Type
    const :line_number, Integer
    const :column, Integer

    sig { returns(String) }
    def to_s
      "[#{line_number}:#{column}] #{literal}, #{type}"
    end
  end
end
