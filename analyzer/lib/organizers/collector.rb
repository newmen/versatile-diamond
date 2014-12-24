module VersatileDiamond
  using Patches::RichString

  module Organizers

    # Provides methods for creating methods for get access to all collection
    # and for storing new item to collection
    module Collector

      # Defines two method for get a full collection or for store new item of
      # collection
      # @param [Array] names the array of collection names
      def collector_methods(*names)
        names.each do |name|
          method = :"#{name.to_s.pluralize}"
          var = :"@#{method}"
          set_var_method_name = :"set_#{method}_default_value_if_need"

          # Gets a collection of concepts
          # @return [Array] collection
          define_method(method) do
            send(set_var_method_name)
          end

          # Adds new item to collection
          # @param [Object] item the item from which self instance depended
          define_method(:"store_#{name}") do |item|
            send(set_var_method_name)
            instance_variable_get(var) << item
          end

          define_method(set_var_method_name) do
            instance_variable_get(var) || instance_variable_set(var, [])
          end
          private set_var_method_name
        end
      end
    end

  end
end
