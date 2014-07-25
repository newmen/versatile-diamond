module VersatileDiamond
  module Generators
    module Code

      # Provides methods that allows to wrap some another empty specie
      # @abstract
      class EmptySpecieWrapper
        extend TotalDelegator

        deligate_to :@specie

        # Remembers empty specie which will be wrapped
        # @param [EmptySpecie | SpecieWrapper] empty_specie the specie which will be
        #   wrapped
        def initialize(empty_specie)
          @specie = empty_specie
          @index = inc_specie_index
        end

        # Gets the class name of current specie code instance
        # @return [String] the class name of specie code instance
        def class_name
          result = @specie.class_name
          @@_counter[spec.name] > 1 ? "#{result}#{@index}" : result
        end

        # Gets the base class of cpp class of symmetric specie
        # @return [String] the name of base class
        def base_class_name
          add_args = additional_template_args.map { |arg| ", #{arg}" }.join
          "#{wrapper_class_name}<#{@specie.base_class_name}#{add_args}>"
        end

      private

        # Increments internal index of symmetric specie of wrapped specie
        # @return [Integer] the index of new created symmetric specie
        def inc_specie_index
          @@_counter ||= {}
          @@_counter[spec.name] ||= 0
          @@_counter[spec.name] += 1
        end
      end

    end
  end
end
