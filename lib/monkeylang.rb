# frozen_string_literal: true

# typed: false
require_relative 'monkeylang/version'
require_relative 'monkeylang/lexer'

require 'readline'
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

      # make sure slop options aren't consumed by ARGF
      ARGV.replace opts.arguments

      # if no argument is supplied; start an interactive REPL
      if ARGV.empty?
        while (buf = Readline.readline('> ', true))
          break if buf == 'exit'

          lexer(buf, print_tokens: opts.lexer?)
        end
      end

      ARGV.each do |file|
        contents = File.read(file)
        lexer(contents, print_tokens: opts.lexer?)
      end
    end

    def self.lexer(contents, print_tokens: false)
      lexer = Lexer.new(contents)
      tokens = lexer.each_token.to_a

      # print the tokens if we have enabled it
      puts(tokens.reject { |token| token.type == TokenType::EOF }) if print_tokens
    end
  end
end
