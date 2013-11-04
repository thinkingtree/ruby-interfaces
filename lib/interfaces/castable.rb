module Interfaces
  # a mixin that defines the 'as' method to allow an object to be cast as an interface
  module Castable
    BUILT_IN_CONVERSIONS = {
      Array => :to_a,
      String => :to_s,
      Symbol => :to_sym,
      Integer => :to_i,
      Float => :to_f,
      Hash => :to_h # only on ruby 2.0
    }

    # attempts to convert non-interface types
    def self.convert_type(instance, type)
      method = BUILT_IN_CONVERSIONS[type]
      if method && instance.respond_to?(method)
        instance.send(method)
      else
        raise NonConvertableObjectError, "Don't know how to convert #{instance} to #{type}"
      end
    end

    def as(interface)
      # interface must be a class
      raise InterfaceError, "#{interface} is not a class" unless interface.is_a?(Class)

      # check if object already is an instance of interface
      return self if self.kind_of?(interface)

      # check if interface is really an interface
      if interface < Interface
        # cache the resulting interface so that we can load it faster next
        # time and so that it can save state
        cache = self.instance_variable_get(:@interface_cache)
        unless cache
          cache = {}
          self.instance_variable_set(:@interface_cache, cache)
        end

        cache[interface] ||= begin
          i = interface.new
          delegate = self
          non_implemented_methods = []

          # define singleton methods that delegate back to this object for each abstract method
          interface.abstract_methods.each do |method|
            non_implemented_methods << method unless self.respond_to?(method)
            i.define_singleton_method(method) do |*args|
              delegate.send(method, *args)
            end
          end

          # raise an exception if all abstract methods are not overridden
          unless non_implemented_methods.empty?
            raise NonConformingObjectError, "#{self} does not conform to interface #{interface}.  Expected methods not implemented: #{non_implemented_methods.join(", ")}"
          end

          # define singleton methods that delegate back to this object for each optional method
          interface.optional_methods.each do |method|
            if self.respond_to?(method)
              i.define_singleton_method(method) do |*args|
                delegate.send(method, *args)
              end
            end
          end

          i
        end
      else
        # interface is not really an interface, it's just a Class
        # use some built-in conversions
        Castable.convert_type(self, interface)
      end
    end
  end
end