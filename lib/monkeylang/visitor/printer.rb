# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative '../visitor'

module MonkeyLang
  module Visitor
    # Very simple printing of the abstract syntax tree
    class Printer
      extend T::Sig
      extend T::Generic

      include Visitor

      ResultType = type_member(fixed: ::String)

      sig { override.params(expr: BinaryExpression).returns(::String) }
      def visit_binary_expression(expr)
        paranethesis(expr.operator.literal, expr.left, expr.right)
      end

      sig { override.params(expr: UnaryExpression).returns(::String) }
      def visit_unary_expression(expr)
        paranethesis(expr.operator.literal, expr.right)
      end

      sig { override.params(expr: GroupingExpression).returns(::String) }
      def visit_group_expression(expr)
        paranethesis('group', expr.expression)
      end

      sig { override.params(expr: LiteralExpression).returns(::String) }
      def visit_literal_expression(expr)
        paranethesis(expr.literal)
      end

      sig { params(name: String, exprs: Expression).returns(::String) }
      private def paranethesis(name, *exprs)
        result = "( #{name}"
        exprs.each do |expr|
          result += ' '
          expr.accept(self)
        end
        result += ')'
        result
      end
    end
  end
end
