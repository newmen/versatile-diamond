module VersatileDiamond
  using Patches::RichString

  module Organizers

    # Provides methods for creating methods for get access to all collection
    # and for storing new or remove item from collection
    module DisposedCollector
      include Organizers::Collector

      # Also defines method for remove item
      # @param [Array] names the array of collection names
      alias_method :simple_collector_methods, :collector_methods
      def collector_methods(*names)
        simple_collector_methods(*names)

        names.each do |name|
          # Removes a item from collection
          # @param [Object] item the item from which self instance depended
          define_method("remove_#{name}") do |item|
            send(:"#{name.to_s.pluralize}").delete(item)
          end
        end
      end
    end

  end
end
