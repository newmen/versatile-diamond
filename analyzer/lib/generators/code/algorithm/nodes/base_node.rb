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
          def_delegator :uniq_specie, :spec
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [EngineCode] generator the major code generator
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(generator, uniq_specie, atom)
            @generator = generator
            @uniq_specie = uniq_specie
            @atom = atom

            @_is_anchor, @_is_actual_anchor, @_is_many_used, @_usages_num = nil
            @_atom_properties, @_sub_properties, @_symmetric_atoms = nil
          end

          # Calculates the hash of node
          # @return [Integer]
          def hash
            (uniq_specie.hash << 16) ^ atom.hash
          end

          # Compares current node with another node
          # @param [BaseNode] other comparing node
          # @return [Boolean] are equal or not
          def ==(other)
            uniq_specie == other.uniq_specie && atom == other.atom
          end
          alias :eql? :==

          # Compares current node with another node
          # @param [BaseNode] other comparing node
          # @return [Integer] the comparing result
          def <=>(other)
            order(other, self, :properties) do
              order(self, other, :uniq_specie) do
                order(self, other, :keyname)
              end
            end
          end

          # Checks that target atom is anchor in unique specie
          # @return [Boolean] is anchor or not
          def anchor?
            return @_is_anchor unless @_is_anchor.nil?
            @_is_anchor = uniq_specie.anchor?(atom)
          end

          # Checks that target atom is anchor in original specie
          # @return [Boolean] is anchor or not
          def actual_anchor?
            return @_is_actual_anchor unless @_is_actual_anchor.nil?
            @_is_actual_anchor = uniq_specie.actual_anchor?(atom)
          end

          # Checks that target atom is used many times in unique specie
          # @return [Boolean]
          def used_many_times?
            return @_is_many_used unless @_is_many_used.nil?
            @_is_many_used = uniq_specie.many?(atom)
          end

          # Count usages of target atom in unique specie
          # @return [Integer]
          def usages_num
            @_usages_num ||= uniq_specie.usages_num(atom)
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            @_atom_properties ||= generator.atom_properties(context_spec, atom)
          end

          # Gets properties of atom in inner unique specie instance
          # @return [Organizers::AtomProperties] for instances that stored in node
          def sub_properties
            @_sub_properties ||= uniq_specie.properties_of(atom)
          end

          # @return [Boolean]
          def coincide?
            properties == sub_properties
          end

          # @return [Array]
          def symmetric_atoms
            @_symmetric_atoms ||= uniq_specie.symmetric_atoms(atom)
          end

          # @return [Boolean]
          def symmetric_atoms?
            !symmetric_atoms.empty?
          end

          # Gets the lattice code generator class
          # @return [Code::Lattice] or nil
          def lattice_class
            lattice && generator.lattice_class(lattice)
          end

          # Just for inspect and rspec
          # @return [Symbol]
          def keyname
            (spec.instance_variable_get(:@child) || spec).spec.keyname(atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{keyname}:#{properties})"
          end

        private

          attr_reader :generator

        end

      end
    end
  end
end
