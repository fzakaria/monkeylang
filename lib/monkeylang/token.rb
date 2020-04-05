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

    const :literal, String
    const :type, Type
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
