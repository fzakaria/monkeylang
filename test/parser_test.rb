# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'monkeylang/parser'
require 'monkeylang/visitor/printer'

class ParserTest < Minitest::Test
  include MonkeyLang

  def test_simple_grouping
    input = <<~MONKEYLANG
      (1 + 2)
    MONKEYLANG

    string_io = StringIO.new
    visitor = Visitor::Printer.new string_io

    lexer = Lexer.new(input)
    parser = MonkeyLang::Parser.new(lexer.each_token.to_a)
    exprs = parser.parse

    assert_equal 1, exprs.size
    T.must(exprs[0]).accept visitor
    assert_equal '(group (+ 1.0 2.0))', string_io.string
  end
end
