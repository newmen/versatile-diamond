module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Collects all defined variables as references from variable instances
        class RelationsDictionary < BaseDictionary

          # @return [AtomType]
          def atom
            var_of(:atom) || store!(Core::Variable[:atom, AtomType[].ptr, 'atom'])
          end

          # @param [Concepts::Bond] rel
          # @option [String] :name
          # @return [Core::Variable]
          def crystal_counter(rel = nil)
            if rel
              var_of(rel) ||
                store!(Core::Variable[rel, TYPE_TYPE, counter_name(rel)])
            else
              var_of(:crystal) ||
                atom_call_counter(:crystal, 'nCrystal', 'crystalNeighboursNum')
            end
          end

          # @return [Core::Variable]
          def amorph_counter
            var_of(:amorph) ||
              atom_call_counter(:amorph, 'nFree', 'amorphNeighboursNum')
          end

          # @return [Core::Variable]
          def double_counter
            var_of(:double) ||
              atom_call_counter(:double, 'nDouble', 'doubleNeighboursNum')
          end

          # @return [Boolean]
          def double_counter?
            !!var_of(:double)
          end

          # @return [Core::Variable]
          def triple_counter
            var_of(:triple) ||
              atom_call_counter(:triple, 'nTriple', 'tripleNeighboursNum')
          end

          # @return [Boolean]
          def triple_counter?
            !!var_of(:triple)
          end

          # @return [Core::Variable]
          def actives_counter
            var_of(:*) || atom_call_counter(:*, 'actives', 'actives')
          end

        private

          TYPE_TYPE = Core::ScalarType['ushort'].freeze

          # @param [String] method_name which will be called
          # @option [String] :name
          # @return [Core::Variable]
          def atom_call_counter(instance, name, method_name)
            value = atom.call(method_name)
            store!(Core::Variable[instance, TYPE_TYPE, name, value: value])
          end

          # @param [Concepts::Bond] rel
          # @return [String]
          def counter_name(rel)
            "n#{rel.dir.to_s.classify}_#{rel.face}"
          end
        end

      end
    end
  end
end
