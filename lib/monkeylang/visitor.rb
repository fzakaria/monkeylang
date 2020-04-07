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

    ResultType = type_member

    sig { abstract.params(expr: BinaryExpression).returns(ResultType) }
    def visit_binary_expression(expr); end

    sig { abstract.params(expr: UnaryExpression).returns(ResultType) }
    def visit_unary_expression(expr); end

    sig { abstract.params(expr: GroupingExpression).returns(ResultType) }
    def visit_group_expression(expr); end

    sig { abstract.params(expr: LiteralExpression).returns(ResultType) }
    def visit_literal_expression(expr); end
  end
end
