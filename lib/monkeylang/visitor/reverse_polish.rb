# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative '../visitor'

module MonkeyLang
  module Visitor
    # Very simple printing of the abstract syntax tree
    # in reverse polish notation
    class ReversePolishPrinter
      extend T::Sig
      extend T::Generic

      include Visitor

      sig { params(io: T.any(IO, StringIO)).void }
      def initialize(io)
        @io = io
      end

      sig { override.params(expr: BinaryExpression).void }
      def visit_binary_expression(expr)
        # perform a post order traversal
        expr.left.accept(self)
        @io.print ' '
        expr.right.accept(self)
        @io.print ' '
        @io.print expr.operator.literal
      end

      sig { override.params(expr: UnaryExpression).void }
      def visit_unary_expression(expr)
        # TODO: How to handle polish order for unary
        expr.right.accept(self)
        @io.print expr.operator.literal
      end

      sig { override.params(expr: GroupingExpression).void }
      def visit_group_expression(expr)
        # enter the expression
        expr.expression.accept(self)
      end

      sig { override.params(expr: LiteralExpression).void }
      def visit_literal_expression(expr)
        @io.print expr.literal
      end

      sig { override.params(expr: PrintExpression).void }
      def visit_print_expression(expr)
        # enter the expression
        expr.expression.accept(self)
      end
    end
  end
end
