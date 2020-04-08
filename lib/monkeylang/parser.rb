# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require 'active_support/core_ext/object'

require_relative 'keyword'
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

    sig { returns(T::Array[Expression]) }
    def parse
      expressions = []
      until end?
        expressions << expression

        # if we are not at the end; we expect a new line or a semi colon
        unless end?
          raise error(peek, 'Expected at SEMI_COLON between expressions') unless match([TokenType::SemiColon])
        end
      end
      expressions
    rescue StandardError
      []
    end

    # expression -> equality ;
    sig { returns(Expression) }
    private def expression
      return print_expression if match([TokenType::Print])

      equality
    end

    sig { returns(PrintExpression) }
    private def print_expression
      expr = expression
      PrintExpression.new expr
    end

    # equality -> comparison ( ( "!=" | "==" ) comparison )* ;
    sig { returns(Expression) }
    private def equality
      expr = comparison

      while match([TokenType::BangEqual, TokenType::EqualEqual])
        operator = previous
        right = comparison
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    # comparison -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
    sig { returns(Expression) }
    private def comparison
      expr = addition

      while match([TokenType::GreaterThan, TokenType::GreaterThanOrEqual,
                   TokenType::LessThan, TokenType::LessThanOrEqual])
        operator = previous
        right = addition
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    # addition   -> multiplication ( ( "-" | "+" ) multiplication )* ;
    sig { returns(Expression) }
    private def addition
      expr = multiplication

      while match([TokenType::Minus, TokenType::Plus])
        operator = previous
        right = multiplication
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    # multiplication -> unary ( ( "/" | "*" ) unary )* ;
    sig { returns(Expression) }
    private def multiplication
      expr = unary

      while match([TokenType::ForwardSlash, TokenType::Asterisk])
        operator = previous
        right = unary
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    # unary  -> ( "!" | "-" ) unary  | primary ;
    sig { returns(Expression) }
    private def unary
      if match([TokenType::Bang, TokenType::Minus])
        operator = previous
        right = unary
        return UnaryExpression.new(operator, right)
      end

      primary
    end

    # primary    -> NUMBER | STRING | "false" | "true" | "nil"
    #                | "(" expression ")" ;
    sig { returns(Expression) }
    private def primary
      return LiteralExpression.new false if match([TokenType::False])
      return LiteralExpression.new true if match([TokenType::True])
      return LiteralExpression.new nil if match([TokenType::Nil])
      return LiteralExpression.new previous.literal if match([TokenType::String])
      return LiteralExpression.new previous.literal.to_f if match([TokenType::Number])

      if match([TokenType::LeftParanthesis])
        expr = expression
        consume(TokenType::RightParanthesis, "Expect ')' after expression")
        return GroupingExpression.new expr
      end

      raise error(peek, 'Expected at NUMBER | STRING | "false" | "true" | "nil" | "(" expression ")"')
    end

    # This is called after an error is caught;
    # we want to read tokens until the next statement
    sig { void }
    private def syncrhonize
      advance
      until end?
        return if previous.type == TokenType::SemiColon

        # if it's a keyword; likely the start of the next statement
        # lets syncrhonize there
        return if KEYWORDS.value? peek.type

        advance
      end
    end

    sig { params(types: T::Array[TokenType]).returns(T::Boolean) }
    private def match(types)
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

    sig { params(type: TokenType, message: String).returns(Token) }
    private def consume(type, message)
      return advance if check(type)

      raise error(peek, message)
    end

    sig { params(token: Token, message: String).returns(RuntimeError) }
    private def error(token, message)
      $stdout.puts "#{token}: #{message}" if token.type == TokenType::EOF

      RuntimeError.new message
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
