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

      sig { params(io: T.any(IO, StringIO)).void }
      def initialize(io)
        @io = io
      end

      sig { override.params(expr: BinaryExpression).void }
      def visit_binary_expression(expr)
        paranethesis(expr.operator.literal, expr.left, expr.right)
      end

      sig { override.params(expr: UnaryExpression).void }
      def visit_unary_expression(expr)
        paranethesis(expr.operator.literal, expr.right)
      end

      sig { override.params(expr: GroupingExpression).void }
      def visit_group_expression(expr)
        paranethesis('group', expr.expression)
      end

      sig { override.params(expr: LiteralExpression).void }
      def visit_literal_expression(expr)
        literal = expr.literal
        literal = 'nil' if literal.nil?
        @io.print literal
      end

      sig { params(name: String, exprs: Expression).void }
      private def paranethesis(name, *exprs)
        @io.print "(#{name}"
        exprs.each do |expr|
          @io.print ' '
          expr.accept(self)
        end
        @io.print ')'
      end
    end
  end
end
