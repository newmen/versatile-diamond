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
                Specie.new(empty_generator, cacher, send(:"dept_#{name}"))
              end
            end
          end

          set(:empty_generator) { stub_generator({}) }
          set(:cacher) { SequencesCacher.new }

          define_code_instances([
            :hydrogen_ion,
            :bridge_base,
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
