module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for detect atom type
        class RelationsCheckerUnit < AtomDetectorUnit
          include ProcsReducer

          # @param [Expressions::RelationsDictionary] dict
          # @param [Organizers::AtomClassifier] classifier
          def initialize(dict, classifier)
            super(dict, classifier)
            @classifier = classifier
          end

          # @return [Expressions::Core::Statement]
          def build_conditions
            call_procs(condition_procs) { assert_return }
          end

        private

          attr_reader :classifier

          # @return [Array]
          # @override
          def real_props
            super.map { |ap| classifier.specificate(ap) }.uniq.sort.reverse
          end

          # @return [Expressions::Core::Statement]
          def assert_return
            Expressions::Core::Assert[Expressions::Core::Constant['false']] +
              Expressions::Core::Return[Expressions::Core::Constant['NO_VALUE']]
          end

          # @return [Array]
          def condition_procs
            real_props.map do |ap|
              -> &block { condition_chain(ap, &block) }
            end
          end

          # @param [Organizers::AtomProperties] ap
          # @yield next condition
          # @return [Expressions::Code::Condition]
          def condition_chain(ap, &block)
            # max_ap = classifier.specificate(ap)
            value = Expressions::Core::Constant[classifier.index(ap)]
            truth = Expressions::Core::Return[value]
            Expressions::AndCondition[compares(ap), truth, block.call]
          end

          # @param [Organizers::AtomProperties] ap
          # @return [Array]
          def compares(ap)
            (simple_nums(ap) + crystal_nums(ap)).map do |var, num|
              Expressions::Core::OpEq[var, Expressions::Core::Constant[num]]
            end
          end

          # @param [Organizers::AtomProperties] ap
          # @return [Hash]
          def simple_nums(ap)
            nums = [[:actives, ap.actives_num]]
            unless amorph_relations.empty?
              nums << [:amorph, ap.undir_bonds_num]
              nums << [:crystal, crystal_nbrs_num(ap)]
            end
            nums << [:double, ap.double_bonds_num] if dict.double_counter?
            nums << [:triple, ap.triple_bonds_num] if dict.triple_counter?
            nums.map { |prefix, num| [dict.public_send(:"#{prefix}_counter"), num] }
          end

          # @param [Organizers::AtomProperties] ap
          # @return [Integer]
          def crystal_nbrs_num(ap)
            ap.nbr_lattices_num + ap.relations.select(&:belongs_to_crystal?).size
          end

          # @param [Organizers::AtomProperties] ap
          # @return [Hash]
          def crystal_nums(ap)
            crystal_relations.map do |rel|
              [dict.crystal_counter(rel), ap.relations.count(rel)]
            end
          end
        end

      end
    end
  end
end
