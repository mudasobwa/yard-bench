# encoding: utf-8

require 'set'

require 'benchmark'

# This should be a DSL used as:
#   benchmark :time => true, :memory => true
# The information should be normalized and collected in a kind of knowledge base

module Yard
  module Bench
    module Marks
      def self.benchmarks meths = nil
        @@benchmarks ||= Set.new
        @@benchmarks.merge meths.select { |m| m.respond_to? :call } if !meths.nil? && meths.respond_to?(:select)
        @@benchmarks
      end
      def self.fails
        @@fails ||= Set.new
      end
      def self.benchmark meth
        puts "Method: [#{meth}], Params: [#{meth.parameters}]" if self.benchmarks.add?(meth)
      end
      def self.fail e
        puts "Exception: [#{e}]]" if self.fails.add?(e)
      end
#    private
      def self.time meth
        puts "a"
        meth.call
        puts "b"
        Benchmark.measure { 1_000.times { meth.call } }.total
      end
    end

    refine Kernel do
      def benchmark *attribs
        puts "#{self.method(:new).parameters}"
        attribs.each do |a|
          puts "#{self.instance_methods(false)}"
          case a.to_sym
          # puts all the methods, defined in this class to benchmarks
          when :*
            # FIXME should here be methods rather than instance_methods?
            Yard::Bench::Marks.benchmarks self.instance_methods(false)
          # puts all the methods, defined in this class and superclasses to benchmarks
          when :**
            # FIXME should here be methods rather than instance_methods?
            Yard::Bench::Marks.benchmarks self.instance_methods(true)
          else
            begin
              Yard::Bench::Marks.benchmark self.instance_method(a.to_sym)
            rescue NameError => e
              Yard::Bench::Marks.fail e
            end
          end
        end
      end
      def benchmark!
        Yard::Bench::Marks.benchmarks.each { |meth|
          puts "Method: [#{meth}], Params: [#{meth.parameters}], Time: [#{Yard::Bench::Marks.time meth}]"
        }
      end
    end
  end
end

module Kernel
  

  def benchmark_other *attribs
    attribs.each do |a|
      c, m = a.split('#')
      begin
        # check if the class is really a class and reachable
        cl = Object.const_get(c)
        if !m.nil? && cl.method_defined?(m.to_sym)
          # FIXME handle m==nil and m="*" and m='regexp' differently
          (@@benchmarks ||= []) << MethodToBenchmark.new(cl, m.to_sym)
        end
      rescue NameError => ne
        # FIXME warn about bad class request in benchmark
        puts "ERROR: #{ne}"
      end
    end
  end
  
  def benchmarkold!
    (@@benchmarks ||= []).each do |bm|
      puts bm.klass.new("olala").send bm.method
      puts Benchmark.realtime {
        if bm.params.nil? || bm.params.size === 0
          1000.times { bm.klass.new("olala").send bm.method }
        else
          1000.times { bm.klass.new.send bm.method, bm.params }
        end
      }
    end
  end
end

using Yard::Bench
  
class BmTester
  benchmark :do_it

  def do_it
    100 ** 2
  end
  def do_other
    2 ** 100
  end

end

BmTester.new.do_it
benchmark!

__END__
kb = `ps -o rss= -p #{$$}`.to_i
puts kb
10.times do
  (1..1_000_000).to_a.map { |m| 1000 - m }
  puts kb - (kb = `ps -o rss= -p #{$$}`.to_i)
end
sleep 5
puts `ps -o rss= -p #{$$}`.to_i
