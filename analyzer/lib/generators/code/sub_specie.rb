module VersatileDiamond
  module Generators
    module Code

      # Provides methods for specie which is used when it is simmetric
      module SubSpecie
        include Code::PolynameClass

        # Defines name methods which are targeted to some prefix
        # @param [String] default_prefix the prefix which will be used by default
        def use_prefix(default_prefix)
          # Gets the class name of current specie
          # @return [String] the class name
          define_method(:class_name) do
            "#{prefix.classify}#{@specie.class_name}"
          end

          # Makes prefix for all names
          # @return [String] the prefix for all names
          define_method(:prefix) do
            return @_prefix if @_prefix

            @_prefix = default_prefix
            original_name = @specie.spec.name
            loop do
              full_name = "#{@_prefix}_#{original_name}".to_sym
              break unless @generator.specie_class(full_name)
              @_prefix = "#{default_prefix}_#{@_prefix}"
            end
            @_prefix
          end
          private :prefix
        end
      end

    end
  end
end
