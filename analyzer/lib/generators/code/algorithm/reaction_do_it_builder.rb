module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Contain logic for building algorithm of reaction applying
        class ReactionDoItBuilder
          include CommonCppExpressions
          include CrystalCppExpressions
          include SpecieCppExpressions
          include SpecificSpecDefiner
          extend Forwardable

          # Initializes algorithm builder
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          def initialize(generator, reaction)
            @generator = generator
            @unique_species_provider = ProxyUniqueSpeciesProvider.new(generator)
            @namer = NameRemember.new

            @reaction = reaction
            @orig_essence_changes = reaction.changes # caches result
            @orig_full_changes = reaction.full_mapping # caches result
            @inv_full_changes = @orig_full_changes.invert # caches result

            @_changes, @_changing_atoms, @_bonds_diff = nil
          end

          # Generates reation applying algorithm cpp code for target reaction
          # @return [String] the string with cpp code of reaction applying algorithm
          def build
            define_species_lines + define_atoms_builder_line + define_atoms_lines +
              phases_changes_lines + recharges_lines + bonds_changes_lines +
              atom_types_changes_lines + collect_desorbes_lines + find_all_call_line
          end

        private

          attr_reader :generator, :namer
          def_delegator :namer, :name_of

          def make_props(specie, atom)
            Organizers::AtomProperties.new(specie.proxy_spec, atom)
          end

          def get_unique_specie(spec)
            spec.gas? ? nil : @unique_species_provider.get_unique_specie(spec)
          end

          def changes
            return @_changes if @_changes
            result = @orig_essence_changes.map do |src_to_prd|
              concept_specs, atoms = src_to_prd.transpose
              uniq_species = concept_specs.map(&method(:get_unique_specie))
              uniq_species.zip(atoms).map do |uniq_specie, atom|
                [uniq_specie, atom]
              end
            end
            @_changes = sort_changes(result)
          end

          def sort_changes(changes)
            changes.sort_by { |src, _| make_props(*src) }
          end

          def source_changes
            changes.map(&:first)
          end

          def source_species
            source_changes.map(&:first)
          end

          def changing_atoms
            @_changing_atoms ||= source_changes.map(&:last)
          end

          ### --------------------------------------------------------------------- ###

          def define_species_lines
            changing_species.map(&method(:define_specie_lines)).join
          end

          def define_specie_lines(specie)
            define_specie_line(specie) + assert_specie_type(specie)
          end

          def define_specie_line(specie)
            namer.assign_next(Specie::INTER_SPECIE_NAME, specie)
            index = @reaction.target_index(specie.spec.spec)
            define_var_line("#{specie_type} *", specie, "target(#{index})")
          end

          def assert_specie_type(specie)
            var_name = name_of(specie)
            code_assert("#{var_name}->type() == #{specie.enum_name}")
          end

          def changing_species
            source_species.compact.uniq
          end

          ### --------------------------------------------------------------------- ###

          def define_atoms_builder_line
            has_gas_source? ? code_line("AtomBuilder #{AtomBuilder::VAR_NAME};") : ''
          end

          def has_gas_source?
            source_species.include?(nil)
          end

          ### --------------------------------------------------------------------- ###

          def define_atoms_lines
            namer.assign(Specie::INTER_ATOM_NAME, changing_atoms)
            define_var_line('Atom *', changing_atoms, atoms_from_species_calls) +
              assert_atom_types
          end

          def atoms_from_species_calls
            changes.map do |(src_specie, src_atom), prd|
              if src_specie
                atom_from_specie_call(src_specie, src_atom)
              else
                atom_builder_call(*prd)
              end
            end
          end

          def atom_builder_call(specie, atom)
            args_str = [specie.role(atom), atom.actives].join(', ')
            "#{AtomBuilder::VAR_NAME}.#{AtomBuilder.method_for(atom)}(#{args_str})"
          end

          def assert_atom_types
            surface_changes = source_changes.select(&:first)
            surface_changes.map { |spec_atom| assert_atom_type(*spec_atom) }.join
          end

          def assert_atom_type(specie, atom)
            code_assert(atom_is_call(atom, specie.role(atom)))
          end

          def atom_is_call(atom, role)
            "#{name_of(atom)}->is(#{role})"
          end

          ### --------------------------------------------------------------------- ###

          def phases_changes_lines
            phases_diff.map { |args| phase_changes_lines_for(*args) }.join
          end

          def phase_changes_lines_for(src_spec, src_atom, prd_spec, prd_atom)
            if src_spec.gas?
              if src_atom.lattice
                insert_to_crystal_line(src_spec, src_atom)
              else
                insert_to_amorph_line(src_atom)
              end
            elsif prd_spec.gas?
              if src_atom.lattice
                erase_from_crystal_line(src_atom)
              else
                erase_from_amorph_line(src_atom)
              end
            elsif src_atom.lattice && !prd_atom.lattice
              erase_from_crystal_line(src_atom) +
                insert_to_amorph_line(src_atom)
            elsif !src_atom.lattice && prd_atom.lattice
              erase_from_amorph_line(src_atom) +
                insert_to_crystal_line(src_spec, src_atom)
            end
          end

          def insert_to_amorph_line(atom)
            amorph_line_action_line(atom, 'insert')
          end

          def erase_from_amorph_line(atom)
            amorph_line_action_line(atom, 'erase')
          end

          def amorph_line_action_line(atom, action)
            code_line("Handbook::amorph().#{action}(#{name_of(atom)});")
          end

          def insert_to_crystal_line(spec, atom)
            nbrs, rel_params = neighbours_with_relation(spec, atom)
            # TODO: logic of neighbours selection depends from diamond crystal lattice!
            fail 'Wrong number of target neighbour atoms' unless nbrs.size == 2

            crystal_func = "#{crystal_call(nbrs.first)}->insert"
            coods_call = full_relation_call_at(nbrs, rel_params)
            code_line("#{crystal_func}(#{name_of(atom)}, #{coods_call});")
          end

          def erase_from_crystal_line(atom)
            var_name = name_of(atom)
            code_line("#{var_name}->lattice()->crystal()->erase(#{var_name});")
          end

          def phases_diff
            @orig_essence_changes.each_with_object([]) do |src_to_prd, acc|
              specs, atoms = src_to_prd.transpose
              lattices = atoms.map(&:lattice)
              are_gases = specs.map(&:gas?)
              if !lattices.all_equal? || (are_gases.any? && !are_gases.all?)
                acc << src_to_prd.flatten
              end
            end
          end

          def neighbour_latticed_atoms(*src_spec_atom)
            prd_spec_atom = @orig_essence_changes[src_spec_atom]
            related_prd = related_with(prd_spec_atom)
            reflected_src = on_source(related_prd)
            avail_src = reflected_src.select { |sa| @orig_essence_changes[sa] }

            source_spec = src_spec_atom.first
            avail_src.select { |s, a| s == source_spec && a.lattice }.map(&:last)
          end

          def neighbours_with_relation(spec, atom)
            nbr_atoms = neighbour_latticed_atoms(spec, atom)
            rel_params = nbr_atoms.map do |nbr_atom|
              pair = spec.links[nbr_atom].find { |a, _| a == atom }
              pair && pair.last.params
            end

            groups = nbr_atoms.zip(rel_params).select(&:last).group_by(&:last)
            max_group = groups.max_by { |_, group| group.size }
            max_group_size = max_group.last.size
            if groups.select { |_, group| group.size == max_group_size }.size > 1
              fail 'Ambigous neighbour atoms groups'
            end

            [max_group.last.map(&:first), max_group.first]
          end

          ### --------------------------------------------------------------------- ###

          def recharges_lines
            actives_changes.map { |args| recharges_lines_for(*args) }.join
          end

          def recharges_lines_for(atom, times)
            method_name = times > 0 ? 'activate' : 'deactivate'
            code_line("#{name_of(atom)}->#{method_name}();") * times.abs
          end

          def actives_changes
            awps_mirror.each_with_object([]) do |awps, acc|
              atoms, props_pair = awps.transpose
              x, y = props_pair.map(&:unbonded_actives_num)
              actives_diff = y - x
              acc << [atoms.first, actives_diff] unless actives_diff == 0
            end
          end

          ### --------------------------------------------------------------------- ###

          def bonds_changes_lines
            process_bonds_lines(:drop) + process_bonds_lines(:create)
          end

          def process_bonds_lines(type)
            bonds_diff[type].map { |args| process_bonds_lines_for(type, *args) }.join
          end

          def process_bonds_lines_for(type, atom, nbrs)
            nbrs.map { |nbr| send("#{type}_bond_line", atom, nbr) }.join
          end

          def process_bond_line(atom, nbr, method_name)
            code_line("#{name_of(atom)}->#{method_name}(#{name_of(nbr)});")
          end

          def drop_bond_line(atom, nbr)
            process_bond_line(atom, nbr, 'unbondFrom')
          end

          def create_bond_line(atom, nbr)
            process_bond_line(atom, nbr, 'bondWith')
          end

          def bonds_diff
            return @_bonds_diff if @_bonds_diff

            result = { drop: {}, create: {} }
            @orig_essence_changes.each do |src, prd|
              drops, adds = find_diffs(src, prd)
              adds = (adds + [src]).uniq if src.first.gas? && !prd.first.gas?
              atom = src.last
              result[:drop][atom] = drops unless drops.empty?
              result[:create][atom] = adds unless adds.empty?
            end

            @_bonds_diff = result
          end

          def find_diffs(*src_to_prd)
            related_src, related_prd = src_to_prd.map { |sa| related_with(*sa) }
            reflected_prd = on_products(related_src)
            diffs = remove_sames(reflected_prd, related_prd)
            diffs.map(&method(:on_source))
          end

          def related_with(spec, atom)
            spec.links[atom].map { |a, _| [spec, a] }
          end

          def on_products(src_spec_atom_list)
            src_spec_atom_list.map { |sa| @orig_full_changes[sa] }
          end

          def on_source(prd_spec_atom_list)
            prd_spec_atom_list.map { |sa| @inv_full_changes[sa] }
          end

          def remove_sames(*prd_spec_atom_lists)
            reflection, products = prd_spec_atom_lists.map(&:to_set)
            [reflection - products, products - reflection].map(&:to_a)
          end

          ### --------------------------------------------------------------------- ###

          def atom_types_changes_lines
            awps_mirror.map { |awps| atom_type_change_lines_for(*awps) }.join
          end

          def atom_type_change_lines_for(*atoms_with_properties)
            atom, wrong_props, trans = trans_props_result(*atoms_with_properties)
            assert_wrong_props_line(atom, wrong_props) +
              atom_type_change_lines(atom, trans)
          end

          def atom_type_change_lines(atom, transitions)
            num = transitions.size
            if num == 0
              fail 'Wrong number of atom types transitions'
            elsif num == 1
              atom_type_change_bodies(atom, transitions).first
             else
              atom_type_change_conditions_lines(atom, transitions).join
            end
          end

          def atom_type_change_conditions_lines(atom, transitions)
            triples = conditions_triples(atom, transitions)
            triples.map do |else_prefix, cond, body_prc|
              code_condition(cond, use_else_prefix: else_prefix, &body_prc)
            end
          end

          def assert_wrong_props_line(atom, wrong_props)
            if wrong_props.empty?
              ''
            else
              conditions = wrong_props.map { |props| props_is_not_call(atom, props) }
              code_assert(conditions.join(' && '))
            end
          end

          def props_is_not_call(atom, props)
            "!#{props_is_call(atom, props)}"
          end

          def props_is_call(atom, props)
            "#{atom_is_call(atom, props_role(props))}"
          end

          def atom_type_change_call(atom, props)
            "#{name_of(atom)}->changeType(#{props_role(props)})"
          end

          def atom_type_conditions(atom, transitions)
            transitions.map(&:first).map { |props| props_is_call(atom, props) }
          end

          def atom_type_change_bodies(atom, transitions)
            transitions.map(&:last).map do |props|
              code_line(atom_type_change_call(atom, props))
            end
          end

          def else_prefix_flags(num)
            [false] + [true] * (num - 1)
          end

          def conditions_triples(atom, transitions)
            else_prefixes = else_prefix_flags(transitions.size)
            conds_str = atom_type_conditions(atom, transitions)
            bodies_str = atom_type_change_bodies(atom, transitions)

            update_last_condition_and_body!(conds_str, bodies_str)
            bodies_procs = bodies_str.map { |body_str| -> { body_str } }
            else_prefixes.zip(conds_str, bodies_procs)
          end

          def update_last_condition_and_body!(conds_ref, bodies_ref)
            last_cond = conds_ref.pop
            conds_ref << nil
            bodies_ref << (code_assert(last_cond) + bodies_ref.pop)
          end

          def props_role(props)
            generator.classifier.index(props)
          end

          def children_props(props)
            generator.classifier.children_of(props).sort
          end

          def trans_props_result(*atoms_with_properties)
            src_props, prd_props = atoms_with_properties.map(&:last)
            children_src_props = children_props(src_props)
            src_props_diffs = children_src_props.map { |child| child - src_props }
            new_prd_props = src_props_diffs.map { |diff| prd_props + diff }
            props_zip = children_src_props.zip(new_prd_props)
            props_groups = props_zip.group_by { |_, new_prd| !new_prd.nil? }
            wrong_props = props_groups[false] ? props_groups[false].map(&:first) : []
            props_transitions = props_groups[true] || []
            atom = atoms_with_properties.first.first
            [atom, wrong_props, props_transitions]
          end

          def awps_mirror
            changes.each_with_object([]) do |src_to_prd, acc|
              if src_to_prd.map(&:first).all?
                atom = src_to_prd.first.last
                acc << src_to_prd.map { |sa| [atom, make_props(*sa)] }
              end
            end
          end

          ### --------------------------------------------------------------------- ###

          def collect_desorbes_lines
            erasing_atoms.map(&method(:remove_atom_lines)).join
          end

          def remove_atom_lines(atom)
            prepare_atom_line(atom) + remove_atom_line(atom)
          end

          def remove_atom_line(atom)
            code_line("Handbook::scavenger().markAtom(#{name_of(atom)});")
          end

          def prepare_atom_line(atom)
            code_line("#{name_of(atom)}->prepareToRemove();")
          end

          def erasing_atoms
            changes.each_with_object([]) do |(src, prd), acc|
              acc << src.last unless prd.first
            end
          end

          ### --------------------------------------------------------------------- ###

          def find_all_call_line
            atoms_var_name = name_of(changing_atoms)
            atom_num = changes.size
            if atom_num == 1
              find_all_call_line_with("&#{atoms_var_name}", 1)
            else
              find_all_call_line_with(atoms_var_name, num)
            end
          end

          def find_all_call_line_with(var_ref, num)
            code_line("Finder::findAll(#{var_ref}, #{num});")
          end
        end

      end
    end
  end
end
