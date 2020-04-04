# frozen_string_literal: true

# typed: strong
require 'sorbet-runtime'

module MonkeyLang
  class Token
    extend T::Sig
    module Type
      ILLEGAL = 'ILLEGAL'
      EOF = 'EOF'
    end
  end
end
