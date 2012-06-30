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
    assert available.has.foo?
    assert available.has?(:foo)
    assert available.need.foo!
    assert available.need!(:foo)
    assert available.errors.empty?
  end

  test "A single hash require" do
    RequireStub.add_available_libs 'bar'

    available = Available.new do
      requires foo: 'bar'
    end

    assert available.satisfied?
    assert available.has.foo?
    assert available.has?(:foo)
    assert available.need.foo!
    assert available.need!(:foo)
    assert available.errors.empty?
  end

  test "A single failed symbol require" do
    available = Available.new do
      requires :foo
    end

    assert !available.satisfied?
    assert !available.has.foo?
    assert !available.has?(:foo)
    assert_raise LoadError do available.need.foo! end
    assert_raise LoadError do available.need!(:foo) end
    assert_equal 1, available.errors.size
  end

  test "A single failed hash require" do
    available = Available.new do
      requires foo: 'bar'
    end

    assert !available.satisfied?
    assert !available.has.foo?
    assert !available.has?(:foo)
    assert_raise LoadError do available.need.foo! end
    assert_raise LoadError do available.need!(:foo) end
    assert_equal 1, available.errors.size
  end

  test "A single optional symbol" do
    RequireStub.add_available_libs 'foo'

    available = Available.new do
      optional :foo
    end

    assert available.satisfied?
    assert available.has.foo?
    assert available.has?(:foo)
    assert available.need.foo!
    assert available.need!(:foo)
    assert available.errors.empty?
  end

  test "A single optional hash" do
    RequireStub.add_available_libs 'bar'

    available = Available.new do
      optional foo: 'bar'
    end

    assert available.satisfied?
    assert available.has.foo?
    assert available.has?(:foo)
    assert available.need.foo!
    assert available.need!(:foo)
    assert available.errors.empty?
  end

  test "A single failed optional symbol" do
    available = Available.new do
      optional :foo
    end

    assert available.satisfied?
    assert !available.has.foo?
    assert !available.has?(:foo)
    assert_raise LoadError do available.need.foo! end
    assert_raise LoadError do available.need!(:foo) end
    assert_equal 1, available.errors.size
  end

  test "A single failed optional hash" do
    available = Available.new do
      optional foo: 'bar'
    end

    assert available.satisfied?
    assert !available.has.foo?
    assert !available.has?(:foo)
    assert_raise LoadError do available.need.foo! end
    assert_raise LoadError do available.need!(:foo) end
    assert_equal 1, available.errors.size
  end
end
