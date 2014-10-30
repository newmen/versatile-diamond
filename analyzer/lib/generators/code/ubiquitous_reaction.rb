module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Contains logic for generation ubiquitous reation
      class UbiquitousReaction < BaseReaction
        include SourceFileCopier

        # Also copies using data file
        # @param [String] root_dir see at #super same argument
        def generate(root_dir)
          super
          copy_file(root_dir, full_data_path)
        end

        # Gets the name of base class
        # @return [String] the parent class name
        def base_class_name
          "#{data_class_name}<#{enum_name}>"
        end

        # Gets the code string with calling environment class generator
        # @return [String] the code string with calling correspond method of
        #   environment coge generator instance
        def gas_concentration
          generator.env.full_concentration_method(gas_spec)
        end

      private

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Ubiquitous'
        end

        # Gets the class name of data file
        # @return [String] the data class name
        def data_class_name
          data_file_name.classify
        end

        # Checks the termination spec of reaction and gets correspond name of data file
        # @return [String] the data file name
        def data_file_name
          if reaction.termination == Concepts::ActiveBond.property
            'deactivation_data'
          else
            'activation_data'
          end
        end

        # Gets the full path to data file
        # @return [String] the path to using data file
        def full_data_path
          "data/#{data_file_name}.h"
        end

        # Gets gas specie which using in reaction
        # @return [Concept::SpecificSpec] the spec from gas phase
        def gas_spec
          spec = reaction.simple_source.first
          raise 'Simple source specie is not gas' unless spec.gas?
          spec
        end

        # Gets the list of more complex reactions
        # @return [Array] the list of children reactions
        def children_reactions
          reaction.complexes.map { |r| generator.reaction_class(r.name) }
        end

        # Gets the list of reaction class generators which are dependent from current
        # @return [Array] the list of dependent reactions code generators
        def body_include_objects
          children_reactions
        end
      end

    end
  end
end
