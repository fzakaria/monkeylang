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

      sig { override.params(expr: LetExpression).void }
      def visit_let_expression(expr)
        T.must(expr.value).accept(self) if expr.value.present?
      end

      sig { override.params(expr: VariableExpression).void }
      def visit_variable_expression(expr)
        @io.print expr.identifier
      end

      sig { override.params(expr: BlockExpression).void }
      def visit_block_expression(expr)
        expr.expressions.each do |e|
          e.accept(self)
        end
      end

      sig { override.params(expr: LogicalExpression).void }
      def visit_logical_expression(expr)
        # TODO
      end

      sig { override.params(expr: WhileExpression).void }
      def visit_while_expression(expr)
        # TODO
      end

      sig { override.params(expr: CallExpression).void }
      def visit_call_expression(expr)
        # TODO
      end

      sig { override.params(expr: FunctionExpression).void }
      def visit_function_expression(expr)
        # TODO
      end

      sig { override.params(expr: ReturnExpression).void }
      def visit_return_expression(expr)
        # TODO
      end

      sig { override.params(expr: IfExpression).void }
      def visit_if_expression(expr)
        expr.condition.accept(self)
        expr.then_expr.accept(self)
        T.must(expr.else_expr).accept(self) if expr.else_expr.present?
      end

      sig { override.params(expr: AssignmentExpression).void }
      def visit_assignment_expression(expr)
        T.must(expr.value).accept(self) if expr.value.present?
      end

      sig { override.params(expr: PrintExpression).void }
      def visit_print_expression(expr)
        # enter the expression
        expr.expression.accept(self)
      end
    end
  end
end
