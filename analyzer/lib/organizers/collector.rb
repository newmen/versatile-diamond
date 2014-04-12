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
          var = :"@#{name}"
          method = :"#{name.to_s.pluralize}"

          # Gets a collection of concepts
          # @return [Array] collection
          define_method(method) do
            instance_variable_get(var) || instance_variable_set(var, [])
          end

          # Adds new item to collection
          # @param [Object] item the item from which self instance depended
          define_method("store_#{name}") do |item|
            send(method) << item
          end
        end
      end
    end

  end
end
