# YARD::Bench

Lazy benchmarking of your project, which appears in the generated [YARD](http://yardoc.org/) documentation.
There is a handy DSL provided to make benchmarking almost without additional effort.

To mark a method(s) for benchmarking, just put

    benchmark :meth1, :meth2  

or

    ⌚ :meth1, :meth2
    
or even

    benchmark :⋅
    
somewhere inside your class declaration. The latter states for benchmarking all the instance methods,
defined in the class. There are four wildcards available:

* `:⋅`  — benchmark instance methods of a class;
* `:⋅⋅` — benchmark instance methods of a class and all the superclasses;
* `:×`  — benchmark class methods of a class;
* `:××` — benchmark class methods of a class and all the superclasses;

Let’s say there is a class `BmExample` that you want to benchmark:

```ruby
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
```

The fifth and sixth lines of code will mark methods `do_it` and `do_other` for benchmarking.
Actual benchmarking will take place during yard documentation production. This definitely will
slow up the documentation generation, but in the production environment these do not
interfere the normal execution timeline at all.

After the generation is done, the methods are measured with an intellectual algorhytm:

![YARD bench results](http://rocket-science.ru/img/yard-bench-result.png)

The results are 〈almost〉 independent of the architecture of the target machine on which
the measurements were done (they are normalized by `1_000_000.times {"foo bar baz".capitalize}`.)
There are meaningful values for amounts of times to test chosen (three results, having
significant figures in hundredth part.) The algorythm calculates the deviation of results and
suggests `O(N)` power of function timing, whether possible.

## Installation

Add this line to your application's Gemfile:

    gem 'yard-bench'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yard-bench

## Usage

Put the following code anywhere within your class:

    benchmark :func1, :func2
    
or even:

    class String
       ⌚ :⋅

and the benchmarks for the chosen functions will be included in yardoc.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
