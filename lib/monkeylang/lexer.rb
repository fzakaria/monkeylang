# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require 'active_support/core_ext/object'

require_relative 'token'
require_relative 'keyword'
module MonkeyLang
  # The lexer for the Monkey language.
  # The goal of a lexer is to turn a string or input stream
  # into a series of tokens.
  class Lexer
    extend T::Sig

    sig { params(input: String).void }
    def initialize(input)
      @input = input
      @position = T.let(0, Integer) # the current position; matches current_char

      @line_number = T.let(1, Integer) # the number of lines processed
      @column = T.let(1, Integer) # the specific column we are at
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
        break if token.type == TokenType::EOF
      end

      enum_for(:each_token)
    end

    # Returns the next token.
    # Will return EOF continuously when called once the end of the file has been reached.
    sig { returns(Token) }
    def next_token
      skip_whitespace

      # if there is no more input; return EOF
      return token(TokenType::EOF) if end?

      current_char = read_character
      next_char = peek_character

      # try to consume a comment
      if current_char == '#'
        read_character until peek_character == "\n" || end?
        # recursively call again
        return next_token
      end

      return string if current_char == '"'

      return identifier if letter?(current_char)

      return number if digit?(current_char)

      # check if it is a known type with two characters
      # we handle these first before the global single case match
      unless end?
        type = TokenType.try_deserialize(current_char + next_char)
        if type.present?
          read_character
          return token(type, current_char + next_char)
        end
      end

      # check if it is a known type
      type = TokenType.try_deserialize(current_char)
      return token(type, current_char) if type.present?

      token(TokenType::Illegal, current_char)
    end

    sig { params(type: TokenType, literal: String).returns(Token) }
    private def token(type, literal = '')
      Token.new(literal: literal, type: type, line_number: @line_number, column: @column)
    end

    # read the next character and advance our read pointer
    sig { returns(String) }
    private def read_character
      @position += 1
      @column += 1
      char = T.must(@input[@position - 1])
      if char == '\n'
        @line_number += 1
        @column = 1
      end
      char
    end

    # peek at the upcoming value
    # returns nothing if we are at the end of the input
    sig { returns(String) }
    private def peek_character
      return '' if end?

      T.must(@input[@position])
    end

    # Peeks at one-after the next value
    # returns nothing if we are at the end of the input
    sig { returns(String) }
    private def peek_next_character
      return '' if (@position + 1) >= @input.size

      T.must(@input[@position + 1])
    end

    # Parse the next set of characters as if they were a string
    # it returns the portion within the quotes
    sig { returns(Token) }
    private def string
      # we do not one because we want to omit the quotes
      start = @position
      loop do
        return token(TokenType::Illegal) if end?

        # if we have a \", then it is an escaped quote not the end of the string
        if peek_character == '\\' && peek_next_character == '"'
          read_character
          read_character
          next
        end

        # consume if its not the end of the string
        if peek_character != '"'
          read_character
          next
        end

        # break out otherwise!
        break
      end

      # advance once past the closing quote
      read_character

      literal = T.must(@input[start...@position - 1])
      token(TokenType::String, literal)
    end

    # Parse the next set of characters as if they were a number
    sig { returns(Token) }
    private def number
      # we subtract one because we advanced our read ahead already
      start = @position - 1
      # while the next letters are digits; consume it to make up an integer
      read_character while digit?(peek_character)

      # check if the current character is now a period
      if peek_character == '.' && digit?(peek_next_character)
        read_character

        # consume the fractional part
        read_character while digit?(peek_character)
      end

      literal = T.must(@input[start...@position])
      token(TokenType::Number, literal)
    end

    # Parse the next set of characters as if they were an identifier or keyword
    sig { returns(Token) }
    private def identifier
      # since we advanced; the start is one behind us
      start = @position - 1

      # consume the next letters if they make up an identifier
      read_character while alpha_numeric?(peek_character)
      literal = T.must(@input[start...@position])
      type = KEYWORDS.fetch(literal, TokenType::Identifier)
      token(type, literal)
    end

    sig { void }
    private def skip_whitespace
      read_character while whitespace?(peek_character)
    end

    sig { returns(T::Boolean) }
    private def end?
      @position >= @input.size
    end

    sig { params(char: String).returns(T::Boolean) }
    private def alpha_numeric?(char)
      letter?(char) || digit?(char)
    end

    # the set of allowable letter characters for identifiers
    # we include _ & ?
    sig { params(char: String).returns(T::Boolean) }
    private def letter?(char)
      return true if %w[_ ?].include?(char)

      (char =~ /[[:alpha:]]/).present?
    end

    sig { params(char: String).returns(T::Boolean) }
    private def digit?(char)
      (char =~ /\d/).present?
    end

    sig { params(char: String).returns(T::Boolean) }
    private def whitespace?(char)
      (char =~ /[[:space:]]/).present?
    end
  end
end
