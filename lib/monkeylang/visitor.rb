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

    sig { abstract.params(expr: PrintExpression).void }
    def visit_print_expression(expr); end
  end
end
