# frozen_string_literal: true

# typed: strict
require 'sorbet-runtime'
require_relative 'expression'
require_relative 'visitor/interpreter'

module MonkeyLang
  # The main interface for callable functions (Class or user defined functions)
  module Callable
    extend T::Sig
    extend T::Helpers
    interface!

    sig do
      abstract.params(interpreter: MonkeyLang::Visitor::Interpreter,
                      arguments: T::Array[T.untyped]).returns(T.untyped)
    end
    def call(interpreter, arguments); end

    sig { abstract.returns(Integer) }
    def arity; end

    # A simple callable that represents a user defined function
    class FunctionCallable
      extend T::Sig
      include Callable

      sig { params(expr: FunctionExpression).void }
      def initialize(expr)
        @expr = expr
      end

      sig do
        override.params(interpreter: MonkeyLang::Visitor::Interpreter,
                        arguments: T::Array[T.untyped]).returns(T.untyped)
      end
      def call(interpreter, arguments)
        environment = Environment.new(interpreter.environment.global_scope)
        @expr.params.map(&:literal).each_with_index do |param, i|
          environment.define(param, arguments[i])
        end
        MonkeyLang::Visitor::Interpreter.execute_block(@expr.body.expressions, interpreter, environment)

        # return the result
        interpreter.result
      end

      sig { override.returns(Integer) }
      def arity
        @expr.params.size
      end

      sig { returns(String) }
      def to_s
        "<fn #{@expr.name.literal}>"
      end
    end

    # A simple callable that just wraps a Proc but is typed
    class NativeCallable
      extend T::Sig
      include Callable

      sig { params(name: String, lambda: T.untyped).void }
      def initialize(name, lambda)
        @name = name
        @lambda = lambda
      end

      sig do
        override.params(interpreter: MonkeyLang::Visitor::Interpreter,
                        arguments: T::Array[T.untyped]).returns(T.untyped)
      end
      def call(interpreter, arguments)
        @lambda.call(*arguments)
      end

      sig { override.returns(Integer) }
      def arity
        @lambda.arity
      end

      sig { returns(String) }
      def to_s
        @name
      end
    end
  end
end
