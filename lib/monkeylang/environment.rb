# frozen_string_literal: true

require 'sorbet-runtime'

# typed: strict
module MonkeyLang
  # The environment holds declarations and their value
  class Environment
    extend T::Sig

    sig { params(scope: Scope).void }
    def initialize(scope = Scope.new)
      @scopes = T.let([], T::Array[Scope])

      # there is always the global scope
      @scopes << scope
    end

    sig { returns(Scope) }
    def global_scope
      T.must(@scopes.first)
    end

    sig { void }
    def push_scope
      @scopes << Scope.new
    end

    sig { void }
    def pop_scope
      @scopes.pop
    end

    sig { params(name: String, value: T.untyped).void }
    def define(name, value)
      current.define(name, value)
    end

    sig { params(name: String, value: T.untyped).void }
    def assign(name, value)
      @scopes.reverse.each do |scope|
        scope.assign(name, value)
        return
      rescue StandardError
        # try next scope
      end

      raise "Undefined variable '#{name}'."
    end

    sig { params(name: String).returns(T.untyped) }
    def get(name)
      @scopes.reverse.each do |scope|
        return scope.get(name)
      rescue StandardError
        # try next scope
      end

      raise "Undefined variable '#{name}'."
    end

    # Return the current local scope
    sig { returns(Scope) }
    private def current
      T.must(@scopes.last)
    end

    # Scope represents the lexical scope
    # which is the variable assignments in each code block
    class Scope
      extend T::Sig

      sig { returns(T::Hash[String, T.untyped]) }
      attr_reader :values

      sig { void }
      def initialize
        @values = T.let({}, T::Hash[String, T.untyped])
      end

      sig { params(name: String, value: T.untyped).void }
      def define(name, value)
        @values[name] = value
      end

      sig { params(name: String, value: T.untyped).void }
      def assign(name, value)
        raise "Undefined variable '#{name}'." unless @values.key? name

        @values[name] = value
      end

      sig { params(name: String).returns(T.untyped) }
      def get(name)
        raise "Undefined variable '#{name}'." unless @values.key? name

        @values[name]
      end
    end
  end
end
