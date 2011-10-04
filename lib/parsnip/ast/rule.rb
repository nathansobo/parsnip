module Parsnip
  module Ast
    class Rule
      attr_reader :name

      def initialize(name, expression)
        @name, @expression = name, expression
      end

      def apply(parser)
        @expression.apply(parser)
      end
    end
  end
end

