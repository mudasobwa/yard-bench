# encoding: utf-8

def init
  super
  sections.last.place(:benchmarks).before(:source)
end
