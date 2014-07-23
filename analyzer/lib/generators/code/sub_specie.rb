module VersatileDiamond
  module Generators
    module Code

      # Provides methods for specie which is used when it is simmetric
      module SubSpecie
        # Defines name methods which are targeted to some prefix
        # @param [String] default_prefix the prefix which will be used by default
        def use_prefix(default_prefix)
          [
            ['class', :classify, ''],
            ['enum', :upcase, '_']
          ].each do |name, method, separator|
            method_name = :"#{name}_name"
            # Gets the #{name} name of current specie
            # @return [String] the #{name} name
            define_method(method_name) do
              value = @specie.public_send(method_name)
              "#{prefix.public_send(method)}#{separator}#{value}"
            end
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
