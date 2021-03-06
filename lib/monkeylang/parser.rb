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
  # declaration -> funDecl
  #             | varDecl
  #             | statement ;
  # statement -> exprStmt
  #           | ifStmt
  #           | printStmt
  #           | whileStmt
  #           | block ;
  # expression -> assignment ;
  # assignment ->  identifier "=" assignment
  #            | logic_or ;
  # logic_or   ->  logic_and ( "or" logic_and )* ;
  # logic_and  ->  equality ( "and" equality )* ;
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
      begin
        expressions << expression until end?
        expressions
      rescue StandardError => e
        puts "Encountered error: #{e.message}"
        # synchronize moves us to the next expression
        # by munging all tokens until the semi-colon
        # This is a friendly way to continue parsing
        synchronize
        # we rely here on Ruby's retry keyword to try the begin/rescue block
        # again
        retry unless end?
        expressions
      end
    end

    # expression -> equality ;
    sig { returns(Expression) }
    private def expression
      return function if match([TokenType::Function])
      return for_expression if match([TokenType::For])
      return if_expression if match([TokenType::If])
      return print_expression if match([TokenType::Print])
      return block_expression if match([TokenType::LeftCurlyBrace])
      return while_expression if match([TokenType::While])
      return let_expression if match([TokenType::Let])

      expr = assignment

      expr
    end

    sig { returns(FunctionExpression) }
    private def function
      name = consume(TokenType::Identifier, 'expected function name.')

      consume(TokenType::LeftParanthesis, "expected '(' after function.")
      arguments = []
      unless check(TokenType::RightParanthesis)
        loop do
          arguments << consume(TokenType::Identifier, 'Expect parameter name')
          break unless match([TokenType::Comma])
        end
      end
      consume(TokenType::RightParanthesis, "expected ')' after parameters.")

      consume(TokenType::LeftCurlyBrace, "expected '{' before body.")
      body = block_expression

      FunctionExpression.new name, arguments, body
    end

    # Lets add for expressions; however we aren't going to add explicit expression nodes
    # rather we are going to "desugar" the for loop by turning it into a WHILE loop!
    sig { returns(Expression) }
    private def for_expression
      consume(TokenType::LeftParanthesis, "Expect '(' after 'if'.")

      initializer = nil
      if match([TokenType::SemiColon])
        initializer = nil
      elsif match([TokenType::Let])
        initializer = let_expression
      else
        initializer = assignment
        consume(TokenType::SemiColon, 'Expected a semi colon after a let expression.')
      end

      condition = nil
      condition = assignment unless check(TokenType::SemiColon)
      consume(TokenType::SemiColon, 'Expected a semi colon after a let expression.')

      increment = nil
      increment = assignment unless check(TokenType::RightParanthesis)
      consume(TokenType::RightParanthesis, 'Expected a semi colon after a let expression.')

      body = expression

      body = BlockExpression.new [body, increment] if increment.present?

      condition = LiteralExpression.new true if condition.nil?

      body = WhileExpression.new condition, body

      body = BlockExpression.new [initializer, body] if initializer.present?

      body
    end

    sig { returns(WhileExpression) }
    private def while_expression
      consume(TokenType::LeftParanthesis, "Expect '(' after 'if'.")
      condition = assignment
      consume(TokenType::RightParanthesis, "Expect ')' after 'if'.")

      body = expression

      WhileExpression.new(condition, body)
    end

    sig { returns(IfExpression) }
    private def if_expression
      consume(TokenType::LeftParanthesis, "Expect '(' after 'if'.")
      condition = assignment
      consume(TokenType::RightParanthesis, "Expect ')' after 'if'.")

      then_expr = expression
      else_expr = nil
      else_expr = expression if match([TokenType::Else])

      IfExpression.new(condition, then_expr, else_expr)
    end

    sig { returns(BlockExpression) }
    private def block_expression
      expressions = []

      until check(TokenType::RightCurlyBrace) || end?
        expressions << expression

        match([TokenType::SemiColon])
      end

      consume(TokenType::RightCurlyBrace, "Expected '}' at the end of the block.")
      BlockExpression.new expressions
    end

    sig { returns(LetExpression) }
    private def let_expression
      identifier = consume(TokenType::Identifier, 'Expected a variable name')

      # We can define a variable without an equality;
      # this is the same as defining the default value
      value = nil
      value = expression if match([TokenType::Equal])

      consume(TokenType::SemiColon, 'Expected a semi colon after a let expression.')

      LetExpression.new identifier.literal, value
    end

    sig { returns(PrintExpression) }
    private def print_expression
      expr = expression
      consume(TokenType::SemiColon, 'Expected a semi colon after a let expression.')
      PrintExpression.new expr
    end

    sig { returns(Expression) }
    private def assignment
      expr = or_expression

      if match([TokenType::Equal])
        equals = previous
        # recursive call here makes it right-associative
        value = assignment
        # The trick is that right before we create the assignment
        # expression node, we look at the left-hand side expression and figure
        # out what kind of assignment target it is.
        # We convert the r-value expression node into an l-value representation.
        #
        # at this point, the original expr must be an identifier (VariableExpression)
        if expr.is_a? VariableExpression
          identifier = expr.identifier

          if match([TokenType::SemiColon])
            consume(TokenType::SemiColon, 'Expected a semi colon after an assignment expression.')
          end
          return AssignmentExpression.new identifier, value
        end
        error(equals, 'Invalid asssignment target.')
      end

      expr
    end

    sig { returns(Expression) }
    private def or_expression
      expr = and_expression

      while match([TokenType::Or])
        operator = previous
        right = and_expression
        expr = LogicalExpression.new(expr, operator, right)
      end

      expr
    end

    sig { returns(Expression) }
    private def and_expression
      expr = equality

      while match([TokenType::And])
        operator = previous
        right = equality
        expr = LogicalExpression.new(expr, operator, right)
      end

      expr
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

      call
    end

    sig { returns(Expression) }
    private def call
      expr = primary
      loop do
        expr = finish_call(expr) if match([TokenType::LeftParanthesis])
        break unless match([TokenType::LeftParanthesis])
      end
      expr
    end

    sig { params(callee: Expression).returns(Expression) }
    private def finish_call(callee)
      arguments = []
      unless check(TokenType::RightParanthesis)
        loop do
          arguments << assignment
          break unless match([TokenType::Comma])
        end
      end

      paren = consume(TokenType::RightParanthesis, "Expect ')' after arguments.")

      CallExpression.new(callee, paren, arguments)
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
      return VariableExpression.new previous.literal if match([TokenType::Identifier])

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
    private def synchronize
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
