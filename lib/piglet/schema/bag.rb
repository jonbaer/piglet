module Piglet
  module Schema
    class Bag
      def initialize(tuple)
        @tuple = tuple
      end
      
      def field_names
        @tuple.field_names
      end
      
      def field_type(name)
        @tuple.field_type(name)
      end
    end
  end
end