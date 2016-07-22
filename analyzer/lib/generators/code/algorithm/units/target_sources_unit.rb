module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Providers methods to define reaction source in reaction applying algorithm
        class TargetSourcesUnit
          include ReactantAbstractType

          # @param [Expressions::TargetsDictionary] dict
          # @param [Array] sources
          def initialize(dict, sources)
            @dict = dict
            @sources = sources.sort

            @surface_nodes = @sources.reject(&:gas?)
            @species = @surface_nodes.map(&:uniq_specie).uniq.sort
            @atoms = @sources.map(&:atom).uniq
          end

          # @return [Expressions::Core::OpCombine]
          def define
            exprs = [define_species]
            exprs << define_builder if adsorption?
            exprs << define_atoms
            exprs.reduce(:+)
          end

        private

          # @return [Boolean]
          def adsorption?
            @sources.any?(&:gas?)
          end

          ### --------------------------------------------------------------------- ###

          # @return [Expressions::Core::OpCombine]
          def define_species
            assign_species + assert_species
          end

          # @return [Expressions::Core::Assign]
          def assign_species
            targets = @dict.make_target_s(@species)
            var = @dict.make_specie_s(@species, type: abstract_type, value: targets)
            var.define_var
          end

          # @return [Expressions::Core::Statement]
          def assert_species
            vars = @species.map(&@dict.public_method(:var_of))
            types = vars.map { |var| var.call('type') }
            enums = @species.map { |s| Expressions::Core::Constant[s.enum_name] }
            assert(types.zip(enums).map { |te| Expressions::Core::OpEq[*te] })
          end

          ### --------------------------------------------------------------------- ###

          # @return [Expressions::Core::Assign]
          def define_builder
            @dict.make_atoms_builder.define_var
          end

          ### --------------------------------------------------------------------- ###

          # @return [Expressions::Core::OpCombine]
          def define_atoms
            assign_atoms + assert_atoms
          end

          # @return [Expressions::Core::Assign]
          def assign_atoms
            inst_call_pairs =
              @sources.zip(atoms_calls).sort_by { |node, expr| [node, expr.code] }
            nodes, calls = inst_call_pairs.transpose
            @dict.make_atom_s(nodes.map(&:atom), value: calls).define_var
          end

          # @return [Array]
          def atoms_calls
            @sources.map do |node|
              if node.gas?
                prd = node.product
                @dict.var_of(:atoms_builder).build(prd.uniq_specie, prd.atom)
              else
                @dict.var_of(node.uniq_specie).atom_value(node.atom)
              end
            end
          end

          # @return [Expressions::Core::Statement]
          def assert_atoms
            nodes = @surface_nodes.sort_by { |n| [n, @dict.var_of(n.atom).code] }
            checks = nodes.map { |n| @dict.var_of(n.atom).role_in(n.uniq_specie) }
            assert(checks)
          end

          ### --------------------------------------------------------------------- ###

          # @param [Array] exprs
          # @return [Expressions::Core::Statement]
          def assert(exprs)
            exprs.map(&Expressions::Core::Assert.public_method(:[])).reduce(:+)
          end
        end

      end
    end
  end
end
