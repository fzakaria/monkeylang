# frozen_string_literal: true

# typed: false
require_relative 'monkeylang/version'
require_relative 'monkeylang/lexer'
require_relative 'monkeylang/parser'
require_relative 'monkeylang/visitor/printer'

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
        o.bool '-a', '--ast', 'print the abstract syntax tree'
        o.on '--version', 'print the version' do
          puts MonkeyLang::VERSION
          exit
        end
      end

      puts "Starting Monkey interpreter...."
      # make sure slop options aren't consumed by ARGF
      ARGV.replace opts.arguments

      # if no argument is supplied; start an interactive REPL
      if ARGV.empty?
        while (buf = Readline.readline('> ', true))
          break if buf == 'exit'

          tokens = lexer(buf, print_tokens: opts.lexer?)
          parse(tokens, print_ast: opts.ast?)
        end
      end

      ARGV.each do |file|
        contents = File.read(file)
        tokens = lexer(contents, print_tokens: opts.lexer?)
        parse(tokens, print_ast: opts.ast?)
      end
    end

    sig { params(contents: String, print_tokens: T::Boolean).returns(T::Array[Token]) }
    def self.lexer(contents, print_tokens: false)
      lexer = Lexer.new(contents)
      tokens = lexer.each_token.to_a

      # print the tokens if we have enabled it
      puts(tokens.reject { |token| token.type == TokenType::EOF }) if print_tokens
      tokens
    end

    sig { params(tokens: T::Array[Token], print_ast: T::Boolean).returns(T.nilable(Expression)) }
    def self.parse(tokens, print_ast: false)
      parser = Parser.new(tokens)
      expression = parser.parse

      string_io = StringIO.new
      printer = Visitor::Printer.new(string_io)
      expression.accept printer if print_ast && expression.present?
      puts string_io.string unless string_io.string.blank?

      expression
    end
  end
end
