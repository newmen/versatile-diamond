module VersatileDiamond
  module Generators
    module Code

      # Creates parents swapped symmetric specie
      class ParentsSwappedSpecie < SwappedSpecie

        # Gets a empty proxy specie
        # @param [Specie] specie the target specie for proxy
        # @return [ParentProxySpecie] the specie which proxing to current specie
        def proxy(specie)
          ParentProxySpecie.new(generator, specie, self)
        end

      private

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class_name
          'ParentsSwapWrapper'
        end

        # Also add original specie class name
        # @return [Array] the array of additional template arguments
        # @override
        def additional_template_args
          [original_specie.class_name] + super
        end
      end

    end
  end
end
