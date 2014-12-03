module SPF
  module Query
    class Directive

      QUALIFIERS = {
        '+' => :pass,
        '-' => :fail,
        '~' => :soft_fail,
        '?' => :neuatral
      }

      attr_reader :name, :value, :qualifier

      def initialize(name,options={})
        @name = name
        @value = options[:value]
        @qualifier = options[:qualifier]
      end

      def to_s
        str = "#{QUALIFIERS.invert[@qualifier]}#{@name}"
        str << ":#{@value}" if value

        return str
      end

    end
  end
end
