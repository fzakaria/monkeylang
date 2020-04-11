# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative 'expression'

module MonkeyLang
  # The main interface for visitors of the AST
  module Visitor
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    interface!

    sig { abstract.params(expr: BinaryExpression).void }
    def visit_binary_expression(expr); end

    sig { abstract.params(expr: UnaryExpression).void }
    def visit_unary_expression(expr); end

    sig { abstract.params(expr: GroupingExpression).void }
    def visit_group_expression(expr); end

    sig { abstract.params(expr: LiteralExpression).void }
    def visit_literal_expression(expr); end

    sig { abstract.params(expr: LetExpression).void }
    def visit_let_expression(expr); end

    sig { abstract.params(expr: VariableExpression).void }
    def visit_variable_expression(expr); end

    sig { abstract.params(expr: AssignmentExpression).void }
    def visit_assignment_expression(expr); end

    sig { abstract.params(expr: BlockExpression).void }
    def visit_block_expression(expr); end

    sig { abstract.params(expr: IfExpression).void }
    def visit_if_expression(expr); end

    sig { abstract.params(expr: LogicalExpression).void }
    def visit_logical_expression(expr); end

    sig { abstract.params(expr: PrintExpression).void }
    def visit_print_expression(expr); end
  end
end
