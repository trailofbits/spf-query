module SPFParse
  class Macro

    attr_reader :letter

    attr_reader :digits

    attr_reader :delimiters

    def initialize(letter,options={})
      @letter     = letter
      @digits     = options[:digits]
      @reverse    = options[:reverse]
      @delimiters = Array(options[:delimiters])
    end

    def reverse?
      @reverse
    end

  end
end
