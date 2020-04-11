# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative '../visitor'
require_relative '../environment'

module MonkeyLang
  module Visitor
    # Very simple printing of the abstract syntax tree
    class Interpreter
      extend T::Sig
      extend T::Generic

      include Visitor

      sig { returns(T.nilable(Object)) }
      attr_reader :result

      sig { returns(Environment) }
      attr_reader :environment

      sig { void }
      def initialize
        @result = T.let(nil, T.untyped)
        @environment = T.let(Environment.new, Environment)
      end

      sig { params(expressions: T::Array[Expression]).returns(T.untyped) }
      def interpret(expressions)
        expressions.map { |expr| evaluate(expr) }.last
      rescue StandardError => e
        "Error: #{e.message}"
      end

      sig { override.params(expr: BinaryExpression).void }
      def visit_binary_expression(expr)
        left = evaluate(expr.left)
        right = evaluate(expr.right)

        case expr.operator.type
        when TokenType::Minus
          @result = left - right
        when TokenType::Plus
          @result = left + right
        when TokenType::ForwardSlash
          @result = left / right
        when TokenType::Asterisk
          @result = left * right
        when TokenType::GreaterThan
          @result = left > right
        when TokenType::GreaterThanOrEqual
          @result = left >= right
        when TokenType::LessThan
          @result = left < right
        when TokenType::LessThanOrEqual
          @result = left <= right
        when TokenType::EqualEqual
          @result = equal?(left, right)
        when TokenType::BangEqual
          @result = !equal?(left, right)
        end
      end

      sig { override.params(expr: UnaryExpression).void }
      def visit_unary_expression(expr)
        right = evaluate(expr.right)

        case expr.operator.type
        when TokenType::Bang
          @result = !true?(right)
        when TokenType::Minus
          @result = -1 * right
        end
      end

      sig { override.params(expr: GroupingExpression).void }
      def visit_group_expression(expr)
        evaluate(expr.expression)
      end

      sig { override.params(expr: LiteralExpression).void }
      def visit_literal_expression(expr)
        @result = expr.literal
      end

      sig { override.params(expr: LetExpression).void }
      def visit_let_expression(expr)
        value = nil
        value = evaluate(T.must(expr.value)) if expr.value.present?
        environment.define(expr.identifier, value)

        @result = value
      end

      sig { override.params(expr: VariableExpression).void }
      def visit_variable_expression(expr)
        @result = environment.get expr.identifier
      end

      sig { override.params(expr: AssignmentExpression).void }
      def visit_assignment_expression(expr)
        value = nil
        value = evaluate(T.must(expr.value)) if expr.value.present?
        environment.assign(expr.identifier, value)

        @result = value
      end

      sig { override.params(expr: BlockExpression).void }
      def visit_block_expression(expr)
        execute_block expr.expressions
      end

      sig { override.params(expr: PrintExpression).void }
      def visit_print_expression(expr)
        puts evaluate(expr.expression)
        @result = nil
      end

      sig { params(expressions: T::Array[Expression]).void }
      private def execute_block(expressions)
        # first thing we do is push a scope
        @environment.push_scope
        begin
          expressions.each do |expression|
            @result = evaluate(expression)
          end
        ensure
          @environment.pop_scope
        end
      end

      sig { override.params(expr: IfExpression).void }
      def visit_if_expression(expr)
        if true? evaluate(expr.condition)
          evaluate(expr.then_expr)
        elsif expr.else_expr.present?
          evaluate(T.must(expr.else_expr))
        end
      end

      sig { params(expr: Expression).returns(T.untyped) }
      private def evaluate(expr)
        expr.accept(self)
        result
      end

      sig { params(obj: T.untyped).returns(T::Boolean) }
      private def true?(obj)
        # we rely on Ruby's double bang operator
        # to turn any object into true or false
        # in Ruby ONLY nil & false are False
        !!obj
      end

      sig { params(lhs: T.untyped, rhs: T.untyped).returns(T::Boolean) }
      private def equal?(lhs, rhs)
        lhs == rhs
      end
    end
  end
end
