module SPFParse
  class Directive

    attr_reader :name, :value, :qualifier

    def initialize(name,options={})
      @name = name
      @value = options[:value]
      @qualifier = options[:qualifier]
    end

  end
end
