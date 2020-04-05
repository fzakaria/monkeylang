# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'

module MonkeyLang
  # The various tokens that are possible in the Monkey language
  class Token < T::Struct
    const :literal, String
    const :type, String
    const :line_number, Integer
    const :column, Integer

    sig { returns(String) }
    def to_s
      "[#{line_number}:#{column}] #{literal}, #{type}"
    end

    module Type
      ILLEGAL = 'ILLEGAL'
      EOF = 'EOF'

      # Identifiers & literals
      IDENTIFIER = 'IDENTIFIER' # ex. add, foobar, x, y
      INTEGER = 'INTEGER' # 123456

      # Operators
      ASSIGN = '='
      PLUS = '+'

      # Delimiters
      COMMA = ','
      SEMICOLON = ';'

      LPAREN = '('
      RPAREN = ')'
      LBRACE = '{'
      RBRACE = '}'

      # Keywords
      FUNCTION = 'FUNCTION'
      LET = 'LET'
      TRUE = 'TRUE'
      FALSE = 'FALSE'
      IF = 'IF'
      ELSE = 'ELSE'
      RETURN = 'RETURN'
    end
  end
end
