module VersatileDiamond
  module Concepts

    # Provides methods for creating methods for get access to all collection
    # and for storing new item to collection
    module Collector

      # Defines two method for get a full collection or for store new item of
      # collection
      # @param [Array] names the array of collection names
      def collector_methods(*names)
        names.each do |name|
          var = :"@#{name}"
          method = :"#{name}s"

          # Gets a collection of concepts
          # @return [Array] collection
          define_method(method) do
            instance_variable_get(var) || instance_variable_set(var, [])
          end

          # Adds new item to collection of concepts
          # @param [Reaction | There] concept the concept from which self spec
          #   depended
          define_method("store_#{name}") do |concept|
            send(method) << concept
          end
        end
      end
    end

  end
end
