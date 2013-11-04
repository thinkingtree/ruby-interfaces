require 'spec_helper'

describe Interfaces::TypedAccessors do
  describe ClassWithTypedAttributes do
    let(:instance) { ClassWithTypedAttributes.new }

    it 'should convert an object to the correct type when it is assigned' do
      instance.field1 = FullyImplimentedClass.new
      instance.field1.should be_a_kind_of(TestInterface)
    end

    it 'should throw an exception if an object that does not conform to the interface is passed' do
      expect { instance.field1 = Object.new }.to raise_error(Interfaces::NonConformingObjectError)
    end

    it 'should allow nil to be assigned' do
      instance.field1 = nil
      instance.field1.should be_nil
    end
  end
end