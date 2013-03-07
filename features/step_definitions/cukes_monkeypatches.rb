# encoding: utf-8

require 'yard-bench'

using Yard::MonkeyPatches

# -----------------------------------------------------------
# --------------------   Kernel   ---------------------------
# -----------------------------------------------------------

Given(/^I define lambda with newly introduced λ alias$/) do
  @cb = λ { |a| a*2 }
  @orig = lambda { |a| a*2 }
end

Given(/^I define proc with newly introduced Λ alias$/) do
  @cb = Λ { |a| a*2 }
  @orig = proc { |a| a*2 }
end

When(/^I call a codeblock defined with “(.*?)”$/) do |arg|
  @result = @cb.call arg
  @expected = @orig.call arg
end

Then(/^the code is being executed and returns proper value \(squared param\)$/) do
  @expected == @result
end

When(/^I call a codeblock defined with “(.*?)” with wrong amount of arguments$/) do |arg|
  @result = (@cb.call(arg, arg, arg) rescue $!)
end

Then(/^I got ArgumentError as the result$/) do
  ArgumentError === @result
end

# -----------------------------------------------------------

Given(/^I define classset as default \((.*)\)$/) do |arg|
  @c = instance_eval("[#{arg}]")
end

When(/^I ask for a random value on a classset$/) do
  @r = random
end

Then(/^the random value should have one of the classes given$/) do
  10.times { @c.include? @r.class }
end

# -----------------------------------------------------------
# --------------------   Randoms   --------------------------
# -----------------------------------------------------------

Given(/^I am `using Yard::MonkeyPatches`$/) do
  # already using in the top of file
end

When(/^I call random of a size (\d+) on a String instance$/) do |sz|
  @i = "".∀ :size => sz.to_i
end

Then(/^the random value should be generated of type String and have length of (\d*)$/) do |sz|
  String === @i && sz.to_i == @i.length
  puts "Generated String: “#{@i}”"
end

When(/^I call random on a Fixnum instance (\d+)$/) do |mx|
  @i = mx.to_i.∀
end

Then(/^the random value should be generated of type Fixnum and be less than (\d+)$/) do |mx|
  Fixnum === @i && @i < mx.to_i
  puts "Generated Fixnum: “#{@i}”"
end

When(/^I call random of a size (\d+) on an Array instance$/) do |sz|
  @i = [].∀ :size => sz.to_i
end

Then(/^the random value should be generated of type Array and have length of (\d+)$/) do |mx|
  Array === @i && mx.to_i == @i.size
  puts "Generated Array (1st element): “#{@i[0]}”"
end

When(/^I call random of a size (\d+) on a Hash instance$/) do |sz|
  @i = {}.∀ :size => sz.to_i
end

Then(/^the random value should be generated of type Hash and have length of (\d+)$/) do |mx|
  Hash === @i && mx.to_i == @i.size
  puts "Generated Hash (1st element): “#{@i.first}”"
end

# -----------------------------------------------------------
# --------------------   Singletons   -----------------------
# -----------------------------------------------------------
  
When(/^I call random of on a String class$/) do
  @i = String.∀
end

Then(/^the random value should be generated of type String and have default length of (\d+)$/) do |sz|
  String === @i && sz.to_i == @i.length
  puts "Generated String: “#{@i}”"
end
