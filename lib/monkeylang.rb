# frozen_string_literal: true

# typed: strict
require_relative 'monkeylang/version'
require_relative 'monkeylang/lexer'
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

      # make sure sloptions aren't consumed by ARGF
      ARGV.replace opts.arguments

      if ARGV.empty?
        puts 'You must provide at least one file.'
        exit 1
      end

      ARGV.each do |file|
        contents = File.read(file)
        lexer = Lexer.new(contents)
        tokens = lexer.each_token.to_a

        # print the tokens if we have enabled it
        puts tokens if opts.lexer?
      end
    end
  end
end
