require 'set'

module Interfaces
  # Interface is meant to be used as a base class for the definition of Interfaces
  class Interface
    def self.abstract(*methods)
      @abstract_methods ||= Set.new
      methods.each do |method|
        # the default implmentation of an abstract method it simply to
        # raise the AbstractMethodInvokedError exception
        define_method(method) do
          raise AbstractMethodInvokedError, "Abstract method #{method} called"
        end
        @abstract_methods << method.to_sym
      end
    end

    # Lists all abstract methods of a class
    def self.abstract_methods
      if self == Interface
        []
      else
        # determine which methods of superclass are still undefined
        nonoverrided_superclass_abtract_methods = superclass.abstract_methods.reject do |m|
          self.instance_methods.include?(m) && self.instance_method(m).owner == self
        end
        ( (@abstract_methods || Set.new) + nonoverrided_superclass_abtract_methods ).to_a
      end
    end

    # True if a class has abstract methods
    def self.abstract?
      !abstract_methods.empty?
    end

    # allow interfaces to be instantiated directly by passing
    # in values for each of the abstract methods
    def initialize(opts = {})
      opts.each_pair do |key, value|

        # only allow initializers for abstract methods
        unless self.class.abstract_methods.include?(key.to_sym)
          raise InterfaceError, "Attempted to assign value to method '#{key}' which is not an abstract method of #{self.class}"
        end

        if value.is_a?(Proc)
          # if the value is a proc then the abstract method
          # override should call that proc
          self.define_singleton_method(key, &value)
        else
          # if the value is not a proc, then the abstract
          # method override should just return the value
          self.define_singleton_method(key) { value }
        end
      end
    end
  end
end