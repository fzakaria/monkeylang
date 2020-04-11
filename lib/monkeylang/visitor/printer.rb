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
        paranethesis(expr.operator.literal, [expr.left, expr.right])
      end

      sig { override.params(expr: UnaryExpression).void }
      def visit_unary_expression(expr)
        paranethesis(expr.operator.literal, [expr.right])
      end

      sig { override.params(expr: GroupingExpression).void }
      def visit_group_expression(expr)
        paranethesis('group', [expr.expression])
      end

      sig { override.params(expr: LiteralExpression).void }
      def visit_literal_expression(expr)
        literal = expr.literal
        literal = 'nil' if literal.nil?
        @io.print literal
      end

      sig { override.params(expr: LetExpression).void }
      def visit_let_expression(expr)
        paranethesis("let #{expr.identifier}", [T.must(expr.value)]) if expr.value.present?
        paranethesis("let #{expr.identifier}") if expr.value.nil?
      end

      sig { override.params(expr: VariableExpression).void }
      def visit_variable_expression(expr)
        paranethesis(expr.identifier)
      end

      sig { override.params(expr: BlockExpression).void }
      def visit_block_expression(expr)
        paranethesis('block', expr.expressions)
      end

      sig { override.params(expr: LogicalExpression).void }
      def visit_logical_expression(expr)
        paranethesis(expr.operator.literal, [expr.left, expr.right])
      end

      sig { override.params(expr: WhileExpression).void }
      def visit_while_expression(expr)
        paranethesis('while', [expr.condition, expr.body])
      end

      sig { override.params(expr: IfExpression).void }
      def visit_if_expression(expr)
        @io.print '(if '
        expr.condition.accept(self)
        @io.print ' then '
        expr.then_expr.accept(self)
        @io.print ' else '
        T.must(expr.else_expr).accept(self) if expr.else_expr.present?
        @io.print ')'
      end

      sig { override.params(expr: AssignmentExpression).void }
      def visit_assignment_expression(expr)
        paranethesis(expr.identifier.to_s, [T.must(expr.value)]) if expr.value.present?
        paranethesis(expr.identifier.to_s) if expr.value.nil?
      end

      sig { override.params(expr: PrintExpression).void }
      def visit_print_expression(expr)
        paranethesis('print', [expr.expression])
      end

      sig { params(name: String, exprs: T::Array[Expression]).void }
      private def paranethesis(name, exprs = [])
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
