module VersatileDiamond
  module Generators
    module Code
      module Support

        # Provides concept instances for RSpec
        module Handbook
          include Tools::Handbook

          # Defines code wrapped dependent species
          class << self
            def define_code_simple_species(concept_names)
              concept_names.each do |name|
                set(:"code_#{name}") do
                  Specie.new(empty_generator, send(:"dept_#{name}"))
                end
              end
            end

            def define_code_species(key, concept_names)
              define_code_instances(:specie_class, key, concept_names)
            end

            def define_code_reactions(key, concept_names)
              define_code_instances(:reaction_class, key, concept_names)
            end

          private

            def define_code_instances(get_class_method_name, key, concept_names)
              concept_names.each do |name|
                set(:"code_#{name}") do
                  dept_spec = send(:"dept_#{name}")
                  generator = stub_generator({ key => [dept_spec] })
                  generator.public_send(get_class_method_name, dept_spec.name)
                end
              end
            end
          end

          set(:empty_generator) { stub_generator({}) }

          define_code_simple_species([
            :hydrogen_ion,
          ])

          define_code_species(:base_specs, [
            :bridge_base,
            :dimer_base,
            :methyl_on_bridge_base,
            :cross_bridge_on_bridges_base,
          ])

          define_code_species(:specific_specs, [
            :activated_bridge,
            :activated_incoherent_bridge,
            :activated_methyl_on_incoherent_bridge,
          ])

          define_code_reactions(:typical_reactions, [
            :dimer_formation,
          ])
        end

      end
    end
  end
end
