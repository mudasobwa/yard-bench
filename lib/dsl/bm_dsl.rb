# encoding: utf-8

require 'set'
require 'benchmark'

require_relative 'monkeypatches'

# This should be a DSL used as:
#   ⌚ :meth1, :meth2
# The information should be normalized and collected in a kind of knowledge base
module Yard
  module Bench
    # Class to be included for benchmarking DSL.
    #
    # It contains `Hash` of the following structure:
    #  — 
    class Marks
      include Yard::MonkeyPatches
      
      class Mark
        attr_reader :times, :memory, :ok
        def initialize(times, memory)
          @times = times
          @memory = memory
          @ok = !@times.nil? && !@memory.nil?
        end
      end
      
      # Standard time for the current processor/ram to normalize benchmarks
      STANDARD_TIME ||= Benchmark.measure { 1_000_000.times { "foo bar baz".capitalize }}.total 

      # Mark specified method of a class to be benchmarkable
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable; may be a wildcard
      # @return [Hash] a set of methods marked benchmarkable for the desired class
      def self.∈ clazz, meth
        get_methods(clazz, meth).map {|m| bm…(clazz)[:methods][m] ||= nil}
      end

      # Mark specified method of a class to be benchmarkable and immediately benchmark
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable; may be a wildcard
      # @return [Hash] a set of methods marked benchmarkable for the desired class
      def self.∈! clazz, meth
        get_methods(clazz, meth).map { |m| bm…(clazz)[:methods][m] ||= self.mark(clazz, m) }
      end

      # Returns benchmarks for the method given by spec (or the whole collection if none specified)
      def self.get file, namespace, m
        # FIXME This might be not yet initialized
        load "#{file}"
        self.∈! Object.const_get(namespace), m
      end
      
      # Calculates benchmarks for all the marked methods
      def self.⌛
        bm… { |c, ms| # "String" => { :class => String, :methods => {…} }
          ms[:methods].each { |m, marks| # { :capitalize => …, :split => nil }
            ms[:methods][m] = self.mark(ms[:class], m) if marks.nil?
            yield ms[:class], m, ms[:methods][m] if block_given?
          }
        }
      end

    private
      def self.mark(clazz, m)
        begin
          (1..10).each { # Sometimes benchmark returns 0 for unknown reason. Ugly hack to mostly avoid.
            mark = Mark.new(⌚(clazz, m), ☑(clazz, m))
            break mark if mark.times[0].values[0] > 0
            log.warn "Benchmarking returns zeroes: #{mark.times}, remeasuring…"
          }
        rescue
          log.warn("Error calculating benchmarks: 〈#{$!}〉")
          Mark.new(nil, nil)
        end
      end
      # Get methods by their name with wildcards.
      # @param clazz [Class] the class to retrieve methods for
      # @param pattern [Symbol] the pattern to get method names for, either symbol,
      #        representing the method, or one of the wildcards “:×”, “:××”, “:⋅”, “:⋅⋅”
      # @return [Array<Symbol>] an array of methods
      def self.get_methods(clazz, pattern)
        case pattern
          # puts all the methods, defined in this class to benchmarks
          when :⋅ then clazz.instance_methods(false)
          # puts all the methods, defined in this class and superclasses to benchmarks
          when :⋅⋅ then clazz.instance_methods(true)
          # puts all the singleton methods, defined in this class to benchmarks
          when :× then clazz.singleton_methods(false)
          # puts all the singleton methods, defined in this class and superclasses to benchmarks
          when :×× then clazz.singleton_methods(true)
          else [pattern]
        end
      end
      
      # Get all the benchmarks for the class. Lazy creates a `Set` to store
      #   benchmarks for future use if there is no benchmarks for the given class yet.
      #
      # @param clazz [Class] the class to return benchmarks for
      # @return [Hash] all the benchmarks, collected from DSL as following
      #     benchmarks = {
      #       "String" => <Hash: {:class => String.class, :methods => {:capitalize => {benchmarks}, :split => nil}}>,
      #       "AClass" => <Hash: {:class => AClass.class, :methods => {:do_it => nil}}>
      #     }
      def self.bm… clazz = nil
        it = (@@benchmarks ||= {}) # Hash { String => { :capitalize => {…}, :split => nil }}
        it = (it[clazz.to_s] ||= {:class => clazz, :methods => {}}) unless clazz.nil?
        if block_given?
          it.each(&Proc.new)
        else
          it
        end
      end

    public
      # Measures the specified method of the class given
      # @param clazz [Class] the class to measure method for
      # @param m [Symbol] the method to measure
      # @param iterations [Fixnum] an amount of iterations to do
      # @return benchmarking total, normalized by STANDARD_TIME and 1_000_000 times
      def self.⌚ clazz, m, iterations = 3
        # Let’ calculate the applicable range
        deg = (1..10).each { |v|
          break v if Benchmark.measure { (10**v).times {clazz.☏ m} }.total > 0.01
        }
        (deg...deg+iterations).to_a.map { |d| 10**d }.map { |e|
          { e => Benchmark.measure { e.times {clazz.☏ m} }.total / STANDARD_TIME }
        }
      end
      # Measures the memory required for a method in KBytes.
      # FIXME This is VERY inaccurate and lame.
      # @param clazz [Class] the class to measure method for
      # @param m [Symbol] the method to measure
      # @param iterations [Fixnum] an amount of iterations to do
      # @return an approximate amount of kilobytes
      def self.☑ clazz, m, iterations = 10
        kb = `ps -o rss= -p #{$$}`.to_i
        iterations.times.map {
          clazz.☏ m
          `ps -o rss= -p #{$$}`.to_i
        }.reduce(&:+) / iterations - kb
      end
    end

    module ::Kernel
      # Mark the task for benchmarking
      # @param attribs [[:rest]] the list of methods to benchmark
      def ⌚ *attribs
        attribs.each { |a| Yard::Bench::Marks.∈ self, a.to_sym }
      end
      alias benchmark ⌚
      
    end
  end
end
