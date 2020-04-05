# frozen_string_literal: true

# typed: false
require 'sorbet-runtime'
require 'active_support/core_ext/object'

require_relative 'token'
require_relative 'keyword'
module MonkeyLang
  # Class of errors that can be thrown by the Lexer. Includes diagnostic information.
  class LexerError < StandardError
    extend T::Sig

    sig { params(msg: String, line_number: Integer, column: Integer).void }
    def initialize(msg, line_number, column)
      @msg = msg
      @line_number = line_number
      @column = column
    end

    sig { returns(String) }
    def to_s
      "[#{@line_number}:#{@column}] #{@msg}"
    end
  end

  # The lexer for the Monkey language.
  # The goal of a lexer is to turn a string or input stream
  # into a series of tokens.
  class Lexer
    extend T::Sig

    sig { params(input: String).void }
    def initialize(input)
      @input = input
      @position = T.let(0, Integer) # the current position; matches current_char
      @read_position = T.let(1, Integer) # the next position to read
      @current_char = T.let('', String) # current character under examination
      @line_number = T.let(0, Integer) # the number of lines processed
      @column = T.let(0, Integer) # the specific column we are at
    end

    # Returns the next token.
    # Will return EOF continuously when called once the end of the file has been reached.
    sig { returns(Token) }
    def next_token
      # if we are at the end of the file simply; return EOF.
      if @position >= @input.size
        return Token.new(literal: '', type: Token::Type::EOF, line_number: @position, column: 0)
      end

      read_character

      case @current_char
      when '='
        return Token.new(literal: @current_char, type: Token::Type::ASSIGN, line_number: @line_number, column: @column)
      when ';'
        return Token.new(literal: @current_char, type: Token::Type::SEMICOLON,
                         line_number: @line_number, column: @column)
      when '('
        return Token.new(literal: @current_char, type: Token::Type::LPAREN, line_number: @line_number, column: @column)
      when ')'
        return Token.new(literal: @current_char, type: Token::Type::RPAREN, line_number: @line_number, column: @column)
      when ','
        return Token.new(literal: @current_char, type: Token::Type::COMMA, line_number: @line_number, column: @column)
      when '+'
        return Token.new(literal: @current_char, type: Token::Type::PLUS, line_number: @line_number, column: @column)
      when '{'
        return Token.new(literal: @current_char, type: Token::Type::LBRACE, line_number: @line_number, column: @column)
      when '}'
        return Token.new(literal: @current_char, type: Token::Type::RBRACE, line_number: @line_number, column: @column)
      end

      if letter?(@current_char)
        start = @position
        read_character
        until letter?(@current_char) || digit(@current_char) || (@current_char == '_') || (@current_char == '?')
          read_character
        end
        literal = @input[start..@position]
        type = KEYWORDS.fetch(literal, Token::Type::IDENTIFIER)
        return Token.new(literal: literal, type: type, line_number: @line_number, column: @column)
      end

      Token.new(literal: @current_char, type: Token::Type::ILLEGAL, line_number: @position, column: @column)
    end

    sig { void }
    private def read_character
      # read the current character
      @current_char = T.must(@input[@position])
      @position += 1
      @column += 1
    end

    sig { params(char: String).returns(T::Boolean) }
    private def letter?(char)
      (char =~ /[[:alpha:]]/).present?
    end

    sig { params(char: String).returns(T::Boolean) }
    private def digit?(char)
      (char =~ /[[:digit:]]/).present?
    end
  end
end
