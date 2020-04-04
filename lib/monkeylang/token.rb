# frozen_string_literal: true

# typed: strong
require 'sorbet-runtime'

module MonkeyLang
  # The various tokens that are possible in the Monkey language
  class Token
    extend T::Sig
    module Type
      ILLEGAL = 'ILLEGAL'
      EOF = 'EOF'
    end
  end
end
