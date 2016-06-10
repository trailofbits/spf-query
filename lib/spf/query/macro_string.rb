module SPF
  module Query
    #
    # Represents a string containing SPF macros.
    #
    class MacroString

      include Enumerable

      #
      # Initializes the macro string.
      #
      # @param [Array<String, Macro>] elements
      #   String literals and String macros.
      #
      def initialize(elements)
        @elements = elements
      end

      #
      # Enumerates over the macro string literals and macros.
      #
      # @yield [element]
      #
      # @yieldparam [String, Macro] element
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def each(&block)
        @elements.each(&block)
      end

      #
      # Accesses the String literal or macro at the given index or range.
      #
      # @param [Integer, (Integer, Integer), Range] arguments
      #   The index or range to access.
      #
      # @return [Array<String, Macro>, String, Macro]
      #   The String literal(s) or macro(s) at the given index or range.
      #
      def [](*arguments)
        @elements[*arguments]
      end

      #
      # Converts the macro string to an Array.
      #
      # @return [Array<String, Macro>]
      #
      def to_a
        @elements
      end

      alias to_ary to_a

      #
      # Converts the macro string to a String.
      #
      # @return [String]
      #
      def to_s
        @elements.join
      end

    end
  end
end
