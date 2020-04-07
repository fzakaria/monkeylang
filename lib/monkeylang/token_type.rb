# frozen_string_literal: true

# typed: true
require 'sorbet-runtime'

# The main module for MonkeyLang
module MonkeyLang
  # An enumeration of all Token types in MonkeyLang
  class Type < T::Enum
    extend T::Sig

    enums do
      Illegal = new('ILLEGAL')
      EOF = new('EOF')

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
      Function = new('fn')
      Let = new('let')
      True = new('true')
      False = new('false')
      If = new('if')
      Else = new('else')
      Return = new('return')
    end

    sig { returns(String) }
    def to_s
      serialize
    end
  end
end
