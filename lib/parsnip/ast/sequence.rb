module Parsnip
  module Ast
    class Sequence
      def initialize(expressions)
        @expressions = expressions
      end

      def apply(parser)
        start_position = parser.position
        @expressions.each do |exp|
          unless exp.apply(parser)
            parser.rewind(start_position)
            return false
          end
        end

        true
      end
    end
  end
end

