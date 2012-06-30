require 'stringio'

module TestSuite
  attr_accessor :name
end

module Kernel
  def suite(name, &block)
    klass = Class.new(Test::Unit::TestCase, &block)
    klass.extend TestSuite
    klass.name = "Suite #{name}"

    klass
  end
  module_function :suite
end

class Test::Unit::TestCase
  def self.inherited(by)
    by.init
    super
  end

  def self.init
    @setups = []
  end

  def self.setup(&block)
    @setups ||= []
    @setups << block
  end

  class << self
    attr_reader :setups
  end

  def setup
    self.class.setups.each do |setup|
      instance_eval(&setup)
    end
    super
  end

  def self.test(desc, &impl)
    define_method("test #{desc}", &impl)
  end

  def capture_stdout
    captured  = StringIO.new
    $stdout   = captured
    yield
    captured.string
  ensure
    $stdout = STDOUT
  end
end
