# frozen_string_literal: true

# typed: true
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
      @read_position = T.let(0, Integer) # the next position to read
      @current_char = T.let('', String) # current character under examination
      @line_number = T.let(0, Integer) # the number of lines processed
      @column = T.let(0, Integer) # the specific column we are at
    end

    sig do
      params(
        blk: T.nilable(T.proc.params(arg0: Token).void)
      ).returns(T::Enumerator[Token])
    end
    def each_token(&blk)
      return enum_for(:each_token) unless block_given?

      loop do
        token = next_token
        blk.call(token)
        break if token.type == Token::Type::EOF
      end

      enum_for(:each_token)
    end

    # Returns the next token.
    # Will return EOF continuously when called once the end of the file has been reached.
    sig { returns(Token) }
    def next_token
      read_character

      skip_whitespace

      # if we are at the end of the file simply; return EOF.
      if @position >= @input.size
        return Token.new(literal: '', type: Token::Type::EOF, line_number: @position, column: 0)
      end

      case @current_char
      when '='
        return Token.new(literal: @current_char, type: Token::Type::Assign, line_number: @line_number, column: @column)
      when ','
        return Token.new(literal: @current_char, type: Token::Type::Comma,
                         line_number: @line_number, column: @column)
      when ';'
        return Token.new(literal: @current_char, type: Token::Type::SemiColon,
                         line_number: @line_number, column: @column)
      when '('
        return Token.new(literal: @current_char, type: Token::Type::LeftParanthesis,
                         line_number: @line_number, column: @column)
      when ')'
        return Token.new(literal: @current_char, type: Token::Type::RightParanthesis,
                         line_number: @line_number, column: @column)
      when '+'
        return Token.new(literal: @current_char, type: Token::Type::Plus, line_number: @line_number, column: @column)
      when '-'
        return Token.new(literal: @current_char, type: Token::Type::Minus, line_number: @line_number, column: @column)
      when '!'
        return Token.new(literal: @current_char, type: Token::Type::Bang, line_number: @line_number, column: @column)
      when '/'
        return Token.new(literal: @current_char, type: Token::Type::ForwardSlash,
                         line_number: @line_number, column: @column)
      when '*'
        return Token.new(literal: @current_char, type: Token::Type::Asterisk,
                         line_number: @line_number, column: @column)
      when '<'
        return Token.new(literal: @current_char, type: Token::Type::LessThan,
                         line_number: @line_number, column: @column)
      when '>'
        return Token.new(literal: @current_char, type: Token::Type::GreaterThan,
                         line_number: @line_number, column: @column)
      when '{'
        return Token.new(literal: @current_char, type: Token::Type::LeftCurlyBrace,
                         line_number: @line_number, column: @column)
      when '}'
        return Token.new(literal: @current_char, type: Token::Type::RightCurlyBrace,
                         line_number: @line_number, column: @column)
      end

      if letter?(@current_char)
        start = @position
        # consume the next letters if they make up an identifier
        read_character while letter?(peek_next) || digit?(peek_next) || (peek_next == '_') || (peek_next == '?')
        literal = T.must(@input[start..@position])
        type = KEYWORDS.fetch(literal, Token::Type::Identifier)
        return Token.new(literal: literal, type: type, line_number: @line_number, column: @column)
      end

      if digit?(@current_char)
        # we subtract one because we advanced our read ahead already
        start = @position
        # while the next letters are digits; consume it to make up an integer
        read_character while digit?(peek_next)
        literal = T.must(@input[start..@position])
        return Token.new(literal: literal, type: Token::Type::Integer, line_number: @line_number, column: @column)
      end

      Token.new(literal: @current_char, type: Token::Type::Illegal, line_number: @position, column: @column)
    end

    sig { void }
    private def read_character
      # read the current character
      @position = @read_position

      return false if @position >= @input.size

      @current_char = T.must(@input[@read_position])

      @read_position += 1
      @column += 1
      return unless @current_char == '\n'

      @column = 0
      @line_number += 1
    end

    # peek at the upcoming value
    # returns nil if we are at the end of the input
    sig { returns(T.nilable(String)) }
    private def peek_next
      @input[@read_position]
    end

    sig { void }
    private def skip_whitespace
      read_character while whitespace?(@current_char) && @position < @input.size
    end

    sig { params(char: T.nilable(String)).returns(T::Boolean) }
    private def letter?(char)
      (char =~ /[[:alpha:]]/).present?
    end

    sig { params(char: T.nilable(String)).returns(T::Boolean) }
    private def digit?(char)
      (char =~ /[[:digit:]]/).present?
    end

    sig { params(char: T.nilable(String)).returns(T::Boolean) }
    private def whitespace?(char)
      (char =~ /[[:space:]]/).present?
    end
  end
end
