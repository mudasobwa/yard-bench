# encoding: utf-8

require 'yard-bench'

using YARD::MonkeyPatches
using YARD::Bench

# @private
module BmTests
  class BmTester
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

# -----------------------------------------------------------
# --------------------   Callers   --------------------------
# -----------------------------------------------------------

Given(/^I have a class with contructor requiring parameters$/) do
  # BmTests::BmTester above
end

When(/^I call a ☎ method on it$/) do
  @inst = BmTests::BmTester.☎
end

Then(/^I have an instance of the class$/) do
  BmTests::BmTester === @inst
end

Given(/^I have an instance method of the class requiring parameters$/) do
  # BmTests::BmTester.do_it above
end

When(/^I call a ☏ method for it$/) do
  @res = BmTests::BmTester.☏ :do_it
end

Then(/^I have params suggested and the method called$/) do
  puts @res
end

# -----------------------------------------------------------
# --------------------   Measures   -------------------------
# -----------------------------------------------------------

Given(/^I marked some methods as benchmarkable$/) do
  class String
    benchmark :capitalize
  end
end

Given(/^I marked all methods of a class as benchmarkable via `:⋅`$/) do
  class BmTests::BmTester
    benchmark :⋅
  end
end

When(/^I call a ⌛ method$/) do
  puts YARD::Bench::Marks.⌛
end

Then(/^I yield all the benchmarks$/) do
  # pending # express the regexp above with the code you wish you had
end

When(/^I call a get method with `BmTests::BmTester`, `do_it` parameters$/) do
  puts YARD::Bench::Marks.get 'BmTests::BmTester', 'do_it'
end

Then(/^I yield the benchmarks for `do_it` method$/) do
  # pending # express the regexp above with the code you wish you had
end

