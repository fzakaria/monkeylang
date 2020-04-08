# frozen_string_literal: true

require 'sorbet-runtime'

# typed: strict
module MonkeyLang
  # The environment holds declarations and their value
  class Environment
    extend T::Sig

    sig { returns(T::Hash[String, T.untyped]) }
    attr_accessor :values

    sig { void }
    def initialize
      @values = T.let({}, T::Hash[String, T.untyped])
    end

    sig { params(name: String, value: T.untyped).void }
    def define(name, value)
      @values[name] = value
    end

    sig { params(name: String).returns(T.untyped) }
    def get(name)
      raise "Undefined variable '#{name}'." unless @values.key? name

      @values[name]
    end
  end
end
