# encoding: utf-8

require 'set'
require 'benchmark'

require_relative 'monkeypatches'

# This should be a DSL used as:
#   benchmark :time => true, :memory => true
# The information should be normalized and collected in a kind of knowledge base

module Yard
  module Bench
    module Marks
      using Yard::MonkeyPatches
      
      def self.⌚
        
      end
      
      # Get all the benchmarks for the class. Lazy creates a `Set` to store
      #   benchmarks for future use if there is no benchmarks for the given class yet.
      #
      # @param clazz [Class] the class to return benchmarks for
      # @param &cb [λ] the codeblock to be executed on each benchmarked method
      # @return [Hash] all the benchmarks, collected from DSL as following
      #     benchmarks = {
      #       String.class => <Set: {:capitalize, :split}>,
      #       AClass.class => <Set: {:*}>
      #     }
      def self.bm… clazz = nil
        it = (@@benchmarks ||= {})
        it = (it[clazz] ||= Set.new) unless clazz.nil?
        if block_given?
          it.each(&Proc.new)
          nil
        else
          it
        end
      end
      def self.fails…
        @@fails ||= Set.new
        block_given? ? @@fails.each(&Proc.new) : @@fails
      end

      # Mark specified method of a class to be bemchmarkable
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable
      def self.bm∈ clazz, meth
        bm…(clazz) << meth
      end
    end

    module ::Kernel
      # Mark the task for benchmarking
      # @param *attribs [[:rest]] the list of methods to benchmark
      def ⌚ *attribs
        attribs.each { |a| Yard::Bench::Marks.bm∈ self.to_s, a.to_sym }
      end
      alias benchmark ⌚

#      STANDARD_TIME = Benchmark.measure { 1_000_000.times { String.∀.capitalize }}
      STANDARD_TIME = Benchmark.measure { 100_000.times { 'Foo Bar Baz'*1024 }}.total

      def ☂⌛ clazz, m
        # Let’ calculate the applicable range
        deg = (1..10).each { |v|
          break v if Benchmark.measure { (10**v).times {clazz.☏ m} }.total > 0.01
        }
        amounts = (deg..deg+2).to_a.map { |d| 10**d }
        amounts.map { |e| Benchmark.measure { e.times {clazz.☏ m} }.total / STANDARD_TIME }
      end

      # It makes no sense to cache methods, params and other metastuff
      #   since the majority of the time takes benchmarking itself
      def ⌛
        Yard::Bench::Marks.bm… { |c, m|
          # Deal with class
          clazz = Kernel.const_get(c) # class of the `c`
          inst = clazz.☎

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
          meths.each { |meth|
            p "#{meth} : #{(inst.method meth).parameters}"
            Benchmark.bm(30) { |x|
              x.report("#{clazz}\##{meth}") { 1_000_000.times { inst.method meth } }
            }
          }
        }
#      begin
#      rescue NameError => e
#        Yard::Bench::Marks.fail e
#      end
      end
    end
  end
end

using Yard::Bench

module BmTests
  class BmTester
    benchmark :do_it, :do_other
    attr_reader :value
    def initialize value, addval, *attrs
      @value = 10 + value + addval
    end
    def do_it deg
      @value * deg
    end
    def do_other base = 2
      base * @value
    end
  end
end
class String
  ⌚ :capitalize
end

res, rest = BmTests::BmTester.☏ :do_it
p res
p BmTests::BmTester.☏ :do_other

#BmTests::BmTester.new.do_it
#puts '-'*30
#puts Yard::Bench::Marks.bm…
#puts Yard::Bench::Marks.bm….reject {|c, m| c !~ /Test/}

#puts '-'*30
#Yard::Bench::Marks.bm…(BmTests::BmTester.to_s) { |m|
#  puts "Method: [#{m}]"
#}

#puts '-'*30
#Yard::Bench::Marks.bm… { |clazz, meth|
#  puts "Class: #{clazz}"
#  meth.each { |m|
#    puts "Method: [#{m}]"
##    puts "Method: [#{meth}], Params: [#{meth.parameters}], Time: [#{Yard::Bench::Marks.time meth}]"
#  }
#}

__END__
kb = `ps -o rss= -p #{$$}`.to_i
puts kb
10.times do
  (1..1_000_000).to_a.map { |m| 1000 - m }
  puts kb - (kb = `ps -o rss= -p #{$$}`.to_i)
end
sleep 5
puts `ps -o rss= -p #{$$}`.to_i
