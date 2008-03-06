module ActiveRelation
  module Sql
    module Quoting
      delegate :quote_table_name, :quote_column_name, :quote, :to => :engine
    end
    
    # module Formatting Context / Strategy # unit test me!!!
    class Strategy
      attr_reader :engine
      include Quoting
      
      def initialize(engine)
        @engine = engine
      end
    end
    
    class Projection < Strategy
      def attribute(relation_name, attribute_name, aliaz)
        "#{quote_table_name(relation_name)}.#{quote_column_name(attribute_name)}" + (aliaz ? " AS #{quote(aliaz.to_s)}" : "")
      end
      
      def select(select_sql, aliaz)
        "(#{select_sql})" + (aliaz ? " AS #{quote(aliaz)}" : "")
      end
    end
    
    class Predicate < Strategy
      def attribute(relation_name, attribute_name, aliaz)
        "#{quote_table_name(relation_name)}.#{quote_column_name(attribute_name)}"
      end
      
      def scalar(scalar, column = nil)
        quote(scalar, column)
      end
      
      def select(select_sql, aliaz)
        "(#{select_sql})"
      end
    end
    
    class Selection < Strategy
      def scalar(scalar)
        scalar
      end
    end
    
    class Relation < Strategy
      def select(select_sql, aliaz)
        select_sql
      end
    end
    
    class Aggregation < Strategy
      def select(select_sql, aliaz)
        "(#{select_sql}) AS #{engine.quote_table_name(aliaz)}"
      end
    end
    
    class Attribute < Predicate
      def initialize(attribute)
        @attribute, @engine = attribute, attribute.engine
      end
      
      def scalar(scalar)
        quote(scalar, @attribute.column)
      end
    end
    
    class Scalar < Predicate
    end
  end
end