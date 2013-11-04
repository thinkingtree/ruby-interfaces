require "interfaces/version"
require "interfaces/interface"
require "interfaces/castable"

module Interfaces
  class InterfaceError < StandardError; end
  class AbstractMethodInvokedError < InterfaceError; end
  class NonConformingObjectError < InterfaceError; end
end

class Object
  include Interfaces::Castable
  Interface = Interfaces::Interface
end