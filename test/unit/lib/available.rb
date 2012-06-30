# encoding: utf-8

require 'available'
require 'available_require_patch'

suite "Available" do
  setup do
    RequireStub.reset!
  end

  test "A single symbol require" do
    RequireStub.add_available_libs 'foo'

    available = Available.new do
      requires :foo
    end

    assert available.satisfied?
  end

  test "A single failed symbol require" do
    available = Available.new do
      requires :foo
    end

    assert !available.satisfied?
  end
end
