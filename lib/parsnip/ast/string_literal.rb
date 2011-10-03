module Parsnip
  module Ast
    class StringLiteral
      def initialize(string)
        @string = string
      end

      def apply(parser)
        parser.match_string(@string)
      end
    end
  end
end

