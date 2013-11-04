require 'spec_helper'

describe Interfaces::Interface do
  describe TestInterface do
    subject  { TestInterface }

    it { should be_abstract}

    it 'can define abstract methods' do
      subject.abstract_methods.should =~ [:method1, :method2, :method3]
    end

    it 'can define optional methods' do
      subject.optional_methods.should =~ [:opt_method]
    end

    it 'can be instantiated with a hash to override abstract methods with constants or Procs' do
      i = subject.new(:method1 => 1, :method2 => 2, :method3 => lambda { |x| x + 1 }, :opt_method => 4)
      i.method1.should == 1
      i.method2.should == 2
      i.method3(2).should == 3
      i.opt_method.should == 4
    end

    it 'will raise an exception if an abstract method is called' do
      expect { subject.new(:method1 => 1, :method2 => 2).method3 }.to raise_error(Interfaces::AbstractMethodInvokedError)
    end

    it 'will return nil if a non-overridden optional method is called' do
      subject.new(:method1 => 1, :method2 => 2).opt_method.should be_nil
    end
  end

  describe TestSubInterface do
    subject  { TestSubInterface }

    it { should be_abstract }

    it 'should inherit abstract methods of base interface' do
      subject.abstract_methods.should =~ [:method1, :method2, :method3, :method4]
    end
  end

  describe TestSubInterfaceWithOverride do
    subject  { TestSubInterfaceWithOverride }

    it 'should be able to override an abstract method defined in its base interface' do
      subject.abstract_methods.should =~ [:method1, :method2, :method4]
    end
  end

  describe FullyImplimentedClass do
    subject  { FullyImplimentedClass }

    it { should_not be_abstract }
    its(:abstract_methods) { should be_empty }
  end
end