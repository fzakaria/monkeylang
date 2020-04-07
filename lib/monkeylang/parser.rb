# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require 'active_support/core_ext/object'

require_relative 'token'
require_relative 'expression'
module MonkeyLang
  # The Parser for the Monkey language.
  # The goal of a parser is to turn a list of tokens
  # into an abstract syntax tree
  #
  # expression -> equality ;
  # equality   -> comparison ( ( "!=" | "==" ) comparison )* ;
  # comparison -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
  # addition   -> multiplication ( ( "-" | "+" ) multiplication )* ;
  # multiplication -> unary ( ( "/" | "*" ) unary )* ;
  # unary      -> ( "!" | "-" ) unary
  #                | primary ;
  # primary    -> NUMBER | STRING | "false" | "true" | "nil"
  #                | "(" expression ")" ;
  class Parser
    extend T::Sig

    sig { params(tokens: T::Array[Token]).void }
    def initialize(tokens)
      @tokens = tokens
      @position = T.let(0, Integer)
    end

    sig { void }
    def parse; end

    # expression -> equality ;
    sig { void }
    private def expression
      equality
    end

    # equality -> comparison ( ( "!=" | "==" ) comparison )* ;
    sig { returns(Expression) }
    private def equality
      expr = comparison

      while match(TokenType::BangEqual, TokenType::EqualEqual)
        operator = previous
        right = comparison
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    # comparison -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
    sig { returns(Expression) }
    private def comparison
      equality
    end

    sig { params(types: TokenType).returns(T::Boolean) }
    private def match(*types)
      found = types.any? { |type| check(type) }
      advance if found
      found
    end

    sig { params(type: TokenType).returns(T::Boolean) }
    private def check(type)
      return false if end?

      peek.type == type
    end

    sig { returns(Token) }
    private def advance
      @position += 1 unless end?

      previous
    end

    sig { returns(T::Boolean) }
    private def end?
      @position >= @tokens.size || peek.type == TokenType::EOF
    end

    sig { returns(Token) }
    private def peek
      T.must(@tokens[@position])
    end

    sig { returns(Token) }
    private def previous
      T.must(@tokens[@position - 1])
    end
  end
end