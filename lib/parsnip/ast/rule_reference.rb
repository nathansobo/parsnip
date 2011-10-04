module Parsnip
  module Ast
    class RuleReference
      def initialize(name)
        @name = name
      end

      def apply(parser)
        parser.apply(@name)
      end
    end
  end
end


