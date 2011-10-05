module Parsnip
  module Ast
    class Choice
      attr_reader :alternatives

      def initialize(alternatives)
        @alternatives = alternatives
      end

      def apply(parser)
        start_position = parser.position

        alternatives.each do |alt|
          if value = alt.apply(parser)
            return value
          else
            parser.rewind(start_position)
          end
        end

        return false
      end
    end
  end
end
