require "interfaces/version"
require "interfaces/interface"
require "interfaces/castable"
require "interfaces/typed_accessors"

module Interfaces
  class InterfaceError < StandardError; end
  class AbstractMethodInvokedError < InterfaceError; end
  class NonConformingObjectError < InterfaceError; end
  class NonConvertableObjectError < InterfaceError; end
end

class Object
  include Interfaces::Castable
  Interface = Interfaces::Interface
end

class Class
  include Interfaces::TypedAccessors
end