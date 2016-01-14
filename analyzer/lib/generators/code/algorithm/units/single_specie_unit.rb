module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from specie
        # @abstract
        class SingleSpecieUnit < SimpleUnit

          # Also remember the unique parent specie
          # @param [Array] args passes to #super method
          # @param [UniqueSpecie] target_specie the major specie of current unit
          # @param [Array] atoms which uses for code generation
          def initialize(*args, target_specie, atoms)
            super(*args, atoms)
            @target_specie = target_specie
          end

        private

          attr_reader :target_specie

          # Specifies arguments of super method
          # @option [Boolean] :closure if true then lambda function closes to scope
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def target_symmetries_lambda(**kwargs, &block)
            each_symmetry_lambda(target_specie, **kwargs, &block)
          end

          # Gets the code line with definition of parent specie variable
          # @return [String] the definition of parent specie variable
          def define_target_specie_line
            define_specie_line(target_specie, avail_anchor)
          end

          # Gets the line with defined anchor atoms for each neighbours operation if
          # them need
          #
          # @return [String] the lines with defined anchor atoms variable
          # @override
          def define_nbrs_specie_anchors_lines
            if single?
              super
            else
              (all_defined?(atoms) ? '' : define_target_specie_line) +
                define_nbrs_anchors_line
            end
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_anchors_line
            if (single? && name_of(atoms.first)) || namer.full_array?(atoms)
              ''
            else
              values = atom_values # collect before reassign
              namer.reassign(Specie::ANCHOR_ATOM_NAME, atoms)
              define_var_line('Atom *', atoms, values)
            end
          end

          # Collects the names of atom variables or calls them from own specie
          # @return [Array] the list of atom names or specie calls
          def atom_values
            names_or(atoms, &method(:atom_from_own_specie_call))
          end
        end

      end
    end
  end
end
