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

          def key
            [@specie, @atom]
          end

          def uses_in_species
            pwts = parents_with_twins
            raise 'Twins are different' if pwts.map(&:last).uniq.size > 1

            pwts.map(&:first)
          end

          def noparent?
            parents_with_twins.empty?
          end

          def monoparent?
            parents_with_twins.size == 1
          end

          def inspect
            ""
          end

        private

          attr_reader :generator
          def_delegator :@specie, :spec

          def parents_with_twins
            spec.parents_with_twins_for(atom).map do |parent, twin|
              [specie_class(parent), twin]
            end
          end
        end

      end
    end
  end
end
