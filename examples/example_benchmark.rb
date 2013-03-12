# encoding: utf-8

module BmExamples
  class BmExample
    benchmark :do_it, :do_other
    attr_reader :value
    # Constructor
    # @param value [Fixnum]
    def initialize value, addval, *attrs
      @value = 10 + value + addval
    end
    # @param deg [Fixnum]
    def do_it deg
      @value * deg
    end
    # Produces a power of the parameter.
    # @param base [Fixnum]
    def do_other base = 2
      base * @value
    end
  end
end
