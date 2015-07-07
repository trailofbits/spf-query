module SPF
  module Query
    class MacroString

      include Enumerable

      def initialize(elements)
        @elements = elements
      end

      def each(&block)
        @elements.each(&block)
      end

      def [](*arguments)
        @elements[*arguments]
      end

      def to_a
        @elements
      end

      def to_ary
        @elements
      end

      def to_s
        @elements.join
      end

    end
  end
end
