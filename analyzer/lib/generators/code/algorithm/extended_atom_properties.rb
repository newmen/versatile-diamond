module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Extends atom properties for atom instance store too
        class ExtendedAtomProperties < Tools::TransparentProxy

          binary_operations :==, :eql?, :'<=>', :+, :-,
            :include?, :contained_in?,
            :same_hydrogens?, :same_incoherent?, :same_unfixed?

          avail_unpublic_methods :atom_name, :valence, :lattice,
            :relations, :danglings, :nbr_lattices, :relevants

          # Initializes instance
          # @overload new(specie, atom)
          #   @param [UniqueSpecie] specie the dependent specie from it will be a
          #     context for wrapping atom properties
          #   @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #     atom which properties will be stored
          # @overload new(parent_props, wrapping_props)
          #   @param [ExtendedAtomProperties] parent_props which have created current
          #     new instance
          #   @param [Organizers::AtomProperties] wrapping_props which will be wrapped
          def initialize(*args)
            if args.first.class == self.class
              @parent_props = args.first
              wrapping_props = args.last
            elsif args.first.class == UniqueSpecie
              @atom = args.last
              wrapping_props = Organizers::AtomProperties.new(args.first.spec, @atom)
            else
              raise ArgumentError, 'Wrong types of arguments'
            end
            super(wrapping_props, skip_index: true)
          end

          # Gets internal atom instance
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom instance which deep stored
          def atom
            @atom || @parent_props.atom
          end

          [
            :unrelevanted, :incoherent, :activated, :deactivated
          ].each do |wrapping_method_name|
            # Wraps each defined method to extended atom properties
            # @return [ExtendedAtomProperties] the wrapping result
            define_method(wrapping_method_name) do
              result = original.public_send(wrapping_method_name)
              result && self.class.new(self, result)
            end
          end
        end

      end
    end
  end
end
