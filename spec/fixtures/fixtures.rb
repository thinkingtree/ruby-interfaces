class TestInterface < Interface
  abstract :method1, :method2
  abstract :method3
end

class TestSubInterface < TestInterface
  abstract :method4
end

class TestSubInterfaceWithOverride < TestInterface
  abstract :method4

  # sub interface overrides method3
  def method3(x)
    x * 2
  end
end

class FullyImplimentedClass < TestInterface
  def method1; end
  def method2; end
  def method3; end
end

class ClassConformingToTestInterface
  def method1; 1; end
  def method2; 2; end
  def method3(x); x * 4; end
end

class ClassNotConformingToTestInterface
  def method1; 1; end
  def method2; 2; end
end

class ClassWithTypedAttributes
  typed_attr_accessor :field1 => TestInterface
  typed_attr_writer :field2 => TestInterface
end