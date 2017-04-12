module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for define counters for detect atom type
        class CountersUnit < AtomDetectorUnit
          include Lattices::BasicRelations

          # @param [Expressions::RelationsDictionary] dict
          # @param [Organizers::AtomClassifier] classifier
          def initialize(dict, classifier)
            super(dict, classifier)

            @_all_relations = nil
          end

          # @return [Expressions::Core::Statement]
          def define_counters
            (counters.map(&:define_var) + [check_latticed] + assert_counters).reduce(:+)
          end

        private

          ZERO = Expressions::Core::Constant[0].freeze

          # @return [Array] the list of counter variables
          def counters
            actives_counters + amorph_counters + crystal_counters
          end

          # @return [Array]
          def crystal_counters
            crystal_relations.map(&dict.public_method(:crystal_counter))
          end

          # @return [Array]
          def amorph_counters
            if amorph_relations.empty?
              []
            else
              result = [dict.amorph_counter]
              result << dict.double_counter if amorph_relations.include?(double_bond)
              result << dict.triple_counter if amorph_relations.include?(triple_bond)
              result << dict.crystal_counter
              result
            end
          end

          # @return [Array]
          def actives_counters
            if actives.empty?
              []
            elsif actives.one?
              [dict.actives_counter]
            else
              raise 'Wrong number of possible active bonds types'
            end
          end

          # @return [Set] termination relations
          def actives
            all_relations.reject(&:relation?).reject(&:hydrogen?)
          end

          # @return [Expressions::Core::Condition]
          def check_latticed
            Expressions::Core::Condition[
              check_condition,
              count_crystal_rels.reduce(:+),
              assign_zeros.reduce(:+)
            ]
          end

          # @return [Expressions::Core::OpAnd]
          def check_condition
            Expressions::Core::OpAnd[
              dict.atom.call('lattice'),
              Expressions::Core::OpLess[ZERO, dict.crystal_counter]
            ]
          end

          # @return [Expressions::Core::Statement]
          def assign_zeros
            crystal_relations.map do |rel|
              Expressions::Core::Assign[dict.crystal_counter(rel), value: ZERO]
            end
          end

          # @return [Expressions::Core::Statement]
          def count_crystal_rels
            crystal_relations.map do |rel|
              Expressions::Core::Assign[dict.crystal_counter(rel), value: nbrs_call(rel)]
            end
          end

          # @param [Concepts::Bond] rel
          # @return [Core::OpDot]
          def nbrs_call(rel)
            Expressions::Core::OpDot[
              Expressions::Core::FunctionCall[relation_name(rel), dict.atom],
              Expressions::Core::FunctionCall['num']
            ]
          end

          # @param [Concepts::Bond] rel
          # @return [String]
          def relation_name(rel)
            "#{rel.dir.to_s}_#{rel.face}"
          end

          # @return [Array]
          def assert_counters
            if amorph_relations.empty?
              [assert_only_crystal_relations]
            else
              result = [assert_crystal_relations, assert_simple_valence]
              if dict.double_counter? || dict.triple_counter?
                result << assert_complex_valence
              end
              result
            end
          end

          # @return [Expressions::Core::FunctionCall]
          def atom_valence
            dict.atom.call('valence')
          end

          # @return [Expressions::Core::Assert]
          def assert_only_crystal_relations
            Expressions::Core::Assert[
              Expressions::Core::OpLessEq[
                Expressions::Core::OpPlus[*actives_counters, *crystal_counters],
                atom_valence
              ]
            ]
          end

          # @return [Expressions::Core::Assert]
          def assert_crystal_relations
            Expressions::Core::Assert[
              Expressions::Core::OpEq[
                dict.crystal_counter,
                Expressions::Core::OpPlus[*crystal_counters]
              ]
            ]
          end

          # @return [Expressions::Core::Assert]
          def assert_simple_valence
            Expressions::Core::Assert[
              Expressions::Core::OpLessEq[
                Expressions::Core::OpPlus[
                  dict.actives_counter, dict.amorph_counter, dict.crystal_counter
                ],
                atom_valence
              ]
            ]
          end

          # @return [Expressions::Core::Assert]
          def assert_complex_valence
            two = Expressions::Core::Constant[2]
            three = Expressions::Core::Constant[3]
            mul_class = Expressions::Core::OpMul
            ccs = [dict.actives_counter]
            ccs << mul_class[dict.double_counter, two] if dict.double_counter?
            ccs << mul_class[dict.triple_counter, three] if dict.triple_counter?
            ccs << dict.crystal_counter

            Expressions::Core::Assert[
              Expressions::Core::OpLessEq[
                Expressions::Core::OpPlus[*ccs],
                atom_valence
              ]
            ]
          end
        end

      end
    end
  end
end
