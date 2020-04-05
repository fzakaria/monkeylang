# frozen_string_literal: true

# typed: strict
require_relative 'monkeylang/version'
require 'slop'
require 'sorbet-runtime'

module MonkeyLang
  # The CLI for the monkey language interpreter
  class CLI
    extend T::Sig

    sig { params(argv: T::Array[String]).void }
    def self.run(argv)
      opts = Slop.parse(argv) do |o|
        o.bool '-l', '--lexer', 'print the lexer tokens'
        o.on '--version', 'print the version' do
          puts MonkeyLang::VERSION
          exit
        end
      end
    end
  end
end
