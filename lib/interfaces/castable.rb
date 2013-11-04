module Interfaces
  # a mixin that defines the 'as' method to allow an object to be cast as an interface
  module Castable
    def as(interface)
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

        # define singeton methods that delegate back to this object
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

        i
      end
    end
  end
end