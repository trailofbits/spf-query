module SPFParse
  class Modifier

    attr_reader :name

    attr_reader :value

    def initialize(name,value)
      @name, @value = name, value
    end

  end

  class UnknownModifier < Modifier
  end
end
