module SPF
  module Query
    class Modifier

      attr_reader :name

      attr_reader :value

      def initialize(name,value=nil)
        @name, @value = name, value
      end

      def to_s
        if @value then "#{@name}=#{@value}"
        else           "#{@name}"
        end
      end

    end

    class UnknownModifier < Modifier
    end
  end
end
