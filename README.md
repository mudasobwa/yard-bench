# YARD::Bench

TODO: Write a gem description

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
