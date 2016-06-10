module SPF
  module Query
    #
    # Represents SPF record modifiers.
    #
    class Modifier

      # Modifier name.
      #
      # @return [Symbol]
      attr_reader :name

      # Modifier value.
      #
      # @return [String, MacroString, IP, nil]
      attr_reader :value

      #
      # Initializes the modifier.
      #
      # @param [Symbol] name
      #   Modifier name.
      #
      # @param [String, nil] value
      #   Modifier value.
      #
      def initialize(name,value=nil)
        @name, @value = name, value
      end

      #
      # Converts the modifier to a String.
      #
      # @return [String]
      #
      def to_s
        if @value then "#{@name}=#{@value}"
        else           "#{@name}"
        end
      end

    end

    #
    # Represents non-standard modifier names.
    #
    class UnknownModifier < Modifier
    end
  end
end
