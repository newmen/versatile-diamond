module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Contains logic for generation ubiquitous reation
      class UbiquitousReaction < BaseReaction
        include SourceFileCopier
        include ReactionWithSimpleGas

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

        # Gets the class name of data file
        # @return [String] the data class name
        def data_class_name
          data_file_name.classify
        end

      private

        # Gets the list of more complex reactions
        # @return [Array] the list of children reactions
        # @override
        def children
          super.sort do |a, b|
            aa, ba = [a, b].map(&:atom_of_complex).map do |atom|
              Organizers::AtomProperties.new(atom)
            end

            aa <=> ba
          end
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Ubiquitous'
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

        # Gets the list of reaction class generators which are dependent from current
        # @return [Array] the list of dependent reactions code generators
        def body_include_objects
          children
        end
      end

    end
  end
end
