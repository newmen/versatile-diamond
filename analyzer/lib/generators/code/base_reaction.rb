module VersatileDiamond
  module Generators
    module Code

      # Provides logic for all reation generators
      # @abstract
      class BaseReaction < SoughtClass

        # Initializes reaction code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Organizers::DependentReaction] reaction by which the code will be
        #   generated
        def initialize(generator, reaction)
          super(generator)
          @reaction = reaction
          @_class_name, @_enum_name, @_file_name = nil
        end

        PREF_METD_SEPS.each do |prefix, method, separator|
          method_name = :"#{prefix}_name"
          var_name = :"@_#{method_name}"

          # Makes #{prefix} name for current specie
          # @return [String] the result #{prefix} name
          define_method(method_name) do
            var = instance_variable_get(var_name)
            unless var
              var = reaction.name.split(/\s+/).map(&method).join(separator)
              instance_variable_set(var_name, var)
            end
            var
          end
        end

        # Gets the name of reaction for output it when simulation do
        # @return [String] the name of wrapped reaction
        def print_name
          reaction.name
        end

      private

        attr_reader :reaction

        # The additional path for current instance
        # @return [String] the additional directories path
        # @override
        def template_additional_path
          'reactions'
        end
      end

    end
  end
end
