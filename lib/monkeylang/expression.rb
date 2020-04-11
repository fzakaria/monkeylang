# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative 'token_type'
require_relative 'visitor'
# The main module for MonkeyLang
module MonkeyLang
  extend T::Sig
  # The base expression class
  class Expression
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    abstract!

    sig { abstract.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor); end
  end

  # Expression for binary operations
  class BinaryExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :left

    sig { returns(Expression) }
    attr_reader :right

    sig { returns(Token) }
    attr_reader :operator

    sig { params(left: Expression, operator: Token, right: Expression).void }
    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_binary_expression(self)
    end
  end

  # Expression for unary operations
  class UnaryExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :right

    sig { returns(Token) }
    attr_reader :operator

    sig { params(operator: Token, right: Expression).void }
    def initialize(operator, right)
      @operator = operator
      @right = right
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_unary_expression(self)
    end
  end

  # Expression for grouping
  class GroupingExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :expression

    sig { params(expression: Expression).void }
    def initialize(expression)
      @expression = expression
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_group_expression(self)
    end
  end

  # Expression for literal
  class LiteralExpression < Expression
    extend T::Sig

    Literal = T.type_alias { T.nilable(T.any(String, Integer, Float, String, T::Boolean)) }

    sig { returns(Literal) }
    attr_reader :literal

    sig { params(literal: Literal).void }
    def initialize(literal)
      @literal = literal
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_literal_expression(self)
    end
  end

  # Expression for let assignment
  class LetExpression < Expression
    extend T::Sig

    sig { returns(String) }
    attr_reader :identifier

    sig { returns(T.nilable(Expression)) }
    attr_reader :value

    sig { params(identifier: String, value: T.nilable(Expression)).void }
    def initialize(identifier, value)
      @identifier = identifier
      @value = value
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_let_expression(self)
    end
  end

  # Expression for variable access
  class VariableExpression < Expression
    extend T::Sig

    sig { returns(String) }
    attr_reader :identifier

    sig { params(identifier: String).void }
    def initialize(identifier)
      @identifier = identifier
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_variable_expression(self)
    end
  end

  # Expression for variable assignment (if it's been defined)
  class AssignmentExpression < Expression
    extend T::Sig

    sig { returns(String) }
    attr_reader :identifier

    sig { returns(T.nilable(Expression)) }
    attr_reader :value

    sig { params(identifier: String, value: T.nilable(Expression)).void }
    def initialize(identifier, value)
      @identifier = identifier
      @value = value
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_assignment_expression(self)
    end
  end

  # Expression for a block
  class BlockExpression < Expression
    extend T::Sig

    sig { returns(T::Array[Expression]) }
    attr_reader :expressions

    sig { params(expressions: T::Array[Expression]).void }
    def initialize(expressions)
      @expressions = expressions
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_block_expression(self)
    end
  end

  # Expression for an if statement
  class IfExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :condition

    sig { returns(Expression) }
    attr_reader :then_expr

    sig { returns(T.nilable(Expression)) }
    attr_reader :else_expr

    sig { params(condition: Expression, then_expr: Expression, else_expr: T.nilable(Expression)).void }
    def initialize(condition, then_expr, else_expr)
      @condition = condition
      @then_expr = then_expr
      @else_expr = else_expr
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_if_expression(self)
    end
  end

  # Expression for an and/or expression
  class LogicalExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :left

    sig { returns(Token) }
    attr_reader :operator

    sig { returns(Expression) }
    attr_reader :right

    sig { params(left: Expression, operator: Token, right: Expression).void }
    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_logical_expression(self)
    end
  end

  # Expression for a while loop
  class WhileExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :condition

    sig { returns(Expression) }
    attr_reader :body
    sig { params(condition: Expression, body: Expression).void }
    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_while_expression(self)
    end
  end

  # Expression for printing
  # TODO: Move this to a function in standard library later
  class PrintExpression < Expression
    extend T::Sig

    sig { returns(Expression) }
    attr_reader :expression

    sig { params(expression: Expression).void }
    def initialize(expression)
      @expression = expression
    end

    sig { override.type_parameters(:T).params(visitor: Visitor[T.type_parameter(:T)]).void }
    def accept(visitor)
      visitor.visit_print_expression(self)
    end
  end
end
