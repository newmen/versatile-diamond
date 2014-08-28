module VersatileDiamond
  module Generators
    module Code
      module Support

        # Provides concept instances for RSpec
        module Handbook
          include Tools::Handbook

          # Defines code wrapped dependent species
          def self.define_code_instances(concept_names)
            concept_names.each do |name|
              set(:"code_#{name}") do
                dept_spec = send(:"dept_#{name}")
                if dept_spec.simple?
                  Specie.new(empty_generator, dept_spec)
                else
                  key = dept_spec.specific? ? :specific_specs : :base_specs
                  generator = stub_generator({ key => [dept_spec] })
                  generator.specie_class(dept_spec.name)
                end
              end
            end
          end

          set(:empty_generator) { stub_generator({}) }

          define_code_instances([
            :hydrogen_ion,
            :bridge_base,
            :dimer_base,
            :methyl_on_bridge_base,
            :activated_bridge,
            :activated_incoherent_bridge,
            :activated_methyl_on_incoherent_bridge,
            :activated_methyl_on_incoherent_bridge,
            :cross_bridge_on_bridges_base,
          ])

        end

      end
    end
  end
end
