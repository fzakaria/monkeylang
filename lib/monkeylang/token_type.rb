# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

# The main module for MonkeyLang
module MonkeyLang
  # An enumeration of all Token types in MonkeyLang
  class TokenType < T::Enum
    extend T::Sig

    enums do
      Illegal = new('ILLEGAL')
      EOF = new('EOF')

      # Identifiers & literals
      Identifier = new('IDENTIFIER') # ex. add, foobar, x, y
      Number = new('NUMBER') # 123456 or 123.456
      String = new('STRING') # "hello world"

      # Operators
      Equal = new('=')
      EqualEqual = new('==')
      Plus = new('+')
      Minus = new('-')
      Bang = new('!')
      BangEqual = new('!=')
      Asterisk = new('*')
      ForwardSlash = new('/')
      LessThan = new('<')
      LessThanOrEqual = new('<=')
      GreaterThan = new('>')
      GreaterThanOrEqual = new('>=')
      Ampersand = new('&')
      AmpersandAmpersand = new('&&')
      Pipe = new('|')
      PipePipe = new('||')

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
      Super = new('super')
      While = new('while')
      For = new('for')
      Nil = new('nil')
      Class = new('class')
      And = new('and')
      Or = new('or')
      # TODO: Remove once the standard library has been declared
      Print = new('print')
    end

    sig { returns(::String) }
    def to_s
      serialize
    end
  end
end
