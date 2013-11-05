require 'spec_helper'

describe Interfaces::Castable do
  it 'raises an exception when attempting to cast to a non-Class' do
    expect { Object.new.as("something") }.to raise_error(Interfaces::InterfaceError)
  end

  describe 'conversions' do
    it 'can convert to String' do
      :test.as(String).should == "test"
    end

    it 'can convert to Symbol' do
      "test".as(Symbol).should == :test
    end

    it 'can convert to an Array' do
      {:test => 1}.as(Array).should == [[:test, 1]]
    end

    it 'can convert to an Integer' do
      "1".as(Integer).should == 1
    end

    it 'can convert to a Float' do
      "1.1".as(Float).should == 1.1
    end
  end

  describe ClassConformingToTestInterface do
    let(:instance) { ClassConformingToTestInterface.new }
    let(:casted_instance) { instance.as(TestInterface) }

    it 'instance should conform_to the TestInteface' do
      instance.conforms_to?(TestInterface).should be_true
    end

    it 'casted_instance should be an instance of TestInterface' do
      casted_instance.should be_a(TestInterface)
    end

    it 'casted_instance should delegate to the overridden methods' do
      casted_instance.method1.should == 1
      casted_instance.method2.should == 2
      casted_instance.method3(2).should == 8
      casted_instance.opt_method.should == 5
    end

    it 'should return the same casted instance if cast is called multiple times' do
      instance.as(TestInterface).should === casted_instance
    end
  end

  describe FullyImplimentedClass do
    let(:instance) { FullyImplimentedClass.new }

    it 'should just return self if attempting to cast an object that is already the right kind of object' do
      instance.as(TestInterface).should === instance
    end
  end

  describe ClassNotConformingToTestInterface do
    let(:instance) { ClassNotConformingToTestInterface.new }

    it 'should raise an error when casted to TestInterface' do
      expected_message = "#{instance.to_s} does not conform to interface TestInterface.  Expected methods not implemented: method3"
      expect { instance.as(TestInterface) }.to raise_error(Interfaces::NonConformingObjectError, expected_message)
    end
  end
end