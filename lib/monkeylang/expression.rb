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

    sig { abstract.params(visitor: Visitor[T.untyped]).returns(T.untyped) }
    def accept(visitor); end
  end

  # Expression for binary operations
  class BinaryExpression < Expression
    include T::Props
    include T::Props::Serializable
    include T::Props::Constructor

    const :left, Expression
    const :right, Expression
    const :operator, Token

    sig { override.params(visitor: Visitor[T.untyped]).returns(T.untyped) }
    def accept(visitor)
      visitor.visit_binary_expression(self)
    end
  end

  # Expression for unary operations
  class UnaryExpression < Expression
    include T::Props
    include T::Props::Serializable
    include T::Props::Constructor

    const :right, Expression
    const :operator, Token

    sig { override.params(visitor: Visitor[T.untyped]).returns(T.untyped) }
    def accept(visitor)
      visitor.visit_unary_expression(self)
    end
  end

  # Expression for grouping
  class GroupingExpression < Expression
    include T::Props
    include T::Props::Serializable
    include T::Props::Constructor

    const :expression, Expression

    sig { override.params(visitor: Visitor[T.untyped]).returns(T.untyped) }
    def accept(visitor)
      visitor.visit_group_expression(self)
    end
  end

  # Expression for literal
  class LiteralExpression < Expression
    include T::Props
    include T::Props::Serializable
    include T::Props::Constructor

    const :literal, String

    sig { override.params(visitor: Visitor[T.untyped]).returns(T.untyped) }
    def accept(visitor)
      visitor.visit_literal_expression(self)
    end
  end
end
