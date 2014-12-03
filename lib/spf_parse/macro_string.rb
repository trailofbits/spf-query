module SPFParse
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

  end
end
