# encoding: utf-8

require_relative '../lib/dsl/bm_dsl'

# Example module to test benchmarking functionality.
module BmExamples
  # Example class to test benchmarking functionality.
  class BmExample
    benchmark :do_it
    ⌚ :do_other
    
    # The value
    attr_reader :value
    # Constructor.
    # @param value [Fixnum] the value to add to 10 within {#value} initializer.
    # @param addval [Fixnum] another value to add to 10 within {#value} initializer.
    # @param attrs [Hash] additional parameters (ignored.)
    def initialize value, addval, *attrs
      @value = 10 + value + addval
    end
    # Multiplies {#value} by parameter given.
    # @param deg [Fixnum]
    # @return [Fixnum] {#value} multiplied by deg.
    def do_it deg
      @value * deg
    end
    # Produces a power of the parameter given.
    # @param base [Fixnum]
    # @return [Fixnum] {#value} in a power of base
    def do_other base = 2
      @value ** base
    end
  end
end
