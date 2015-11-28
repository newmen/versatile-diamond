module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksAlgorithmBuilder < BaseFindAlgorithmBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            super(generator)
          end

          # Generates lateral chunks algorithm cpp code
          # @return [String] the string with cpp code of lateral chunks algorithm
          def build
            unit = initial_unit
            unit.first_assign!

            unit.define_target_atoms_line +
              unit.check_symmetries do
                factory.remember_names! # do not necessary (it possible just for tests)
                body
              end
          end

        private

          attr_reader :lateral_chunks

          # Gets relations which will checked
          # @param [Array] nodes for which the relations will be gotten
          # @return [Array] the list of relations
          def checking_rels(nodes)
            ordered_graph_from(nodes).first.last
          end

          # Gets cpp code of checking sidepiece species
          # @param [Array] nbrs_with_species the list of tuples with neighbour nodes,
          #   parameter of relation between them and near sidepiece species
          # @yield provides internal body of checking conditions
          # @return [String] the block of cpp code with checking target atoms,
          #   relations between them and sidepiece species which will be gotten from it
          #   atoms
          def check_sidepieces(nbrs_with_species, &block)
            prev_sidepieces = []
            checks_species_procs = nbrs_with_species.map do |rel_args, sidepieces|
              prev_sidepieces_copy = prev_sidepieces
              prev_sidepieces += sidepieces
              check_sidepiece_proc(rel_args, sidepieces, prev_sidepieces_copy)
            end

            factory.restore_names! # do not necessary (it possible just for tests)
            reduce_procs(checks_species_procs, &block).call
          end

          # Gets the proc which checks neighbour sidepiece, it relations and species
          # @param [Array] rel_args the arguments for #relation_proc method
          # @param [Array] sidepieces which will be checked after relations
          # @param [Array] prev_sidepieces the list of sidepieces which was used at
          #   previos steps
          # @return [Proc] which generates cpp code for check the sidepiece
          def check_sidepiece_proc(rel_args, sidepieces, prev_sidepieces)
            rl_proc = relations_proc(*rel_args)
            nbr_atoms = rel_args[1].map(&:atom)
            checker_unit = factory.checker(sidepieces.zip(nbr_atoms), prev_sidepieces)
            -> &block do
              rl_proc.call { checker_unit.define_and_check(&block) }
            end
          end
        end

      end
    end
  end
end
