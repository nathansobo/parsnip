module Parsnip
  module Ast
    class Sequence
      def initialize(expressions)
        @expressions = expressions
      end

      def apply(parser)
        start = parser.pos
        @expressions.each do |exp|
          unless exp.apply(parser)
            parser.rewind(start)
            return false
          end
        end

        true
      end
    end
  end
end

