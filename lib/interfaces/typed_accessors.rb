module Interfaces
  module TypedAccessors
    # use like:
    # typed_attr_accessor :field_name => InterfaceName
    def typed_attr_accessor(attrs)
      # attrs.each_pair |attr_name,interface|
      #   inst_variable_name = "@#{attr_name}"
      #   define_method method_name do
      #     instance_variable_get inst_variable_name
      #   end
      # end

      # use the standard reader
      attrs.keys.each do |attr|
        attr_reader attr
      end

      # also define writers
      typed_attr_writer attrs
    end

    def typed_attr_writer(attrs)
      attrs.each_pair do |attr_name,interface|
        inst_variable_name = "@#{attr_name}"
        define_method "#{attr_name}=" do |new_value|
          instance_variable_set inst_variable_name, new_value.as(interface)
        end
      end
    end
  end
end