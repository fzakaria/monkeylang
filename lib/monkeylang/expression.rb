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
end
