module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains the target species (original and unique) and correspond atom
        # @abstract
        class BaseNode
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie, :atom
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [Specie] original_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(original_specie, uniq_specie, atom)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
            @atom = atom

            @_atom_properties = nil
          end

          # Compares current node with another node
          # @param [BaseNode] other comparing node
          # @return [Integer] the comparing result
          def <=> (other)
            order(other, self, :properties) { comparing_core(other) }
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            @_atom_properties ||= Organizers::AtomProperties.new(dept_spec, atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties})"
          end

        private

          attr_reader :original_specie

          # Provides default comparing core for the case when atom properties are equal
          # @param [BaseNode] other comparing node
          # @return [Integer] the comparing result
          def comparing_core(other)
            0
          end
        end

      end
    end
  end
end
