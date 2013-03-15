# encoding: utf-8

require 'set'
require 'benchmark'

require_relative 'monkeypatches'

# This should be a DSL used as:
#   ⌚ :meth1, :meth2
# The information should be normalized and collected in a kind of knowledge base
module Yard
  module Bench
    # Class to be included for benchmarking DSL
    class Marks
      using Yard::MonkeyPatches
      
      # Standard time for the current processor/ram to normalize benchmarks
      STANDARD_TIME ||= Benchmark.measure { 1_000_000.times { "foo bar baz".capitalize }}.total 

      # Mark specified method of a class to be bemchmarkable
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable
      # @return [Set] a set of methods marked benchmarkable for the desired class
      def self.∈ clazz, meth
        bm…(clazz) << meth
      end

      # Returns benchmarks for the method given by spec (or the whole collection if none specified)
      def self.get namespace = nil, m = nil
        @@marks ||= self.⌛
        return @@marks if namespace.nil?
        
        begin
          # FIXME FIXME FIXME
          @@marks.select { |e| e[:class] == namespace }[0][:methods][m.to_sym]
        rescue NoMethodError
          # This is because result of select is nil and [0] is call to nowhere
          puts $!
        end
      end
      
      # It makes no sense to cache methods, params and other metastuff
      #   since the majority of the time takes benchmarking itself
      def self.⌛
        bm… { |c, m|
          # Deal with class
          clazz = Kernel.const_get(c) # class of the `c`

          meths = []
          m.each { |meth|
            meths |= case meth
              # puts all the methods, defined in this class to benchmarks
              when :⋅ then clazz.instance_methods(false)
              # puts all the methods, defined in this class and superclasses to benchmarks
              when :⋅⋅ then clazz.instance_methods(true)
              # puts all the singleton methods, defined in this class to benchmarks
              when :× then clazz.singleton_methods(false)
              # puts all the singleton methods, defined in this class and superclasses to benchmarks
              when :×× then clazz.singleton_methods(true)
              else [meth]
            end
          }
          
          {
            :class => "#{clazz}", :methods => meths.inject({}) { |agg, meth|
            bm = ⌚(clazz, meth)
            mem = ☑(clazz, meth)
            yield clazz, meth, bm if block_given?
            agg.merge({ meth => {:scope => :instance, :benchmark => bm, :memory => mem} })
          }}
        }
      end

    private
      # Get all the benchmarks for the class. Lazy creates a `Set` to store
      #   benchmarks for future use if there is no benchmarks for the given class yet.
      #
      # @param clazz [Class] the class to return benchmarks for
      # @return [Hash] all the benchmarks, collected from DSL as following
      #     benchmarks = {
      #       String.class => <Set: {:capitalize, :split}>,
      #       AClass.class => <Set: {:*}>
      #     }
      def self.bm… clazz = nil
        it = (@@benchmarks ||= {})
        it = (it[clazz] ||= Set.new) unless clazz.nil?
        if block_given?
          it.map(&Proc.new)
        else
          it
        end
      end
      # FIXME Not yet used: errors, yielded during benchmarking
      def self.fails…
        @@fails ||= Set.new
        block_given? ? @@fails.each(&Proc.new) : @@fails
      end

    public
      # Measures the specified method of the class given
      # @param clazz [Class] the class to measure method for
      # @param m [Symbol] the method to measure
      # @param iterations [Fixnum] an amount of iterations to do
      # @return benchmarking total, normalized by STANDARD_TIME
      def self.⌚ clazz, m, iterations = 3
        # Let’ calculate the applicable range
        deg = (1..10).each { |v|
          break v if Benchmark.measure { (10**v).times {clazz.☏ m} }.total > 0.01
        }
        {
          :times => 10**deg,
          :benchmarks => (deg...deg+iterations).to_a.map { |d| 10**d }.map { |e|
            Benchmark.measure { e.times {clazz.☏ m} }.total / STANDARD_TIME
          }
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
        attribs.each { |a| Yard::Bench::Marks.∈ self.to_s, a.to_sym }
      end
      alias benchmark ⌚
      
    end
  end
end
