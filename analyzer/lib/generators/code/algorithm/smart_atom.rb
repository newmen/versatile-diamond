module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Wraps concept atom and provides useful methods
        class SmartAtom
          include SpeciesUser
          extend Forwardable

          attr_reader :atom

          def initialize(generator, specie, atom)
            @generator = generator
            @specie = specie
            @atom = atom
          end

          def uses_in_species
            parents_with_twins.map(&:first)
          end

          def properties
            Organizers::AtomProperties.new(spec, atom)
          end

          def noparent?
            original_pwts.empty?
          end

          def monoparent?
            original_pwts.size == 1
          end

          def inspect
            ""
          end

        private

          attr_reader :generator
          def_delegator :@specie, :spec

          def parents_with_twins
            original_pwts.map do |parent, twin|
              specie = specie_class(parent)
              smart_twin = self.class.new(generator, specie, twin)
              [specie, smart_twin]
            end
          end

          def original_pwts
            spec.parents_with_twins_for(atom)
          end
        end

      end
    end
  end
end
