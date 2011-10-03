module Parsnip
  module Ast
    class Grammar
      def initialize(rules)
        @rules = {}
        rules.each do |rule|
          @rules[rule.name] = rule
        end
      end

      def parser
        Parser.new(self)
      end

      def apply(rule_name, parser)
        @rules[rule_name].apply(parser)
      end
    end
  end
end

