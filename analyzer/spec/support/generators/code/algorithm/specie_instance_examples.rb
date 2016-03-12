module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          module SpecieInstanceExamples
            shared_context :specie_instance_context do
              let(:specific_specs) { [] }
              let(:typical_reactions) { [] }
              let(:generator) do
                stub_generator(base_specs: base_specs,
                               specific_specs: specific_specs,
                               typical_reactions: typical_reactions)
              end
            end

            shared_context :raw_none_specie_context do
              let(:orig_none_specie) { generator.specie_class(dept_none_specie.name) }
              let(:none_specie_inst) do
                Instances::NoneSpecie.new(generator, orig_none_specie)
              end
            end

            shared_context :none_specie_context do
              include_context :specie_instance_context
              include_context :raw_none_specie_context

              subject { none_specie_inst }

              let(:base_specs) { [dept_none_specie] }
              let(:dept_none_specie) { dept_bridge_base }

              [:ct, :cr, :cl].each do |keyname|
                let(keyname) { dept_none_specie.spec.atom(keyname) }
              end
            end

            shared_context :raw_unique_parent_context do
              def make_proxy(parent, complex)
                mirror = Mcs::SpeciesComparator.make_mirror(complex, parent)
                Organizers::ProxyParentSpec.new(parent, complex, mirror)
              end

              let(:dept_proxy_parent) do
                make_proxy(dept_uniq_parent, dept_uniq_specie)
              end

              let(:uniq_parent_inst) do
                Instances::UniqueParent.new(generator, dept_proxy_parent)
              end

              [:cb, :cm].each do |keyname|
                let(keyname) { dept_uniq_specie.spec.atom(keyname) }
              end
            end

            shared_context :unique_parent_context do
              include_context :specie_instance_context
              include_context :raw_unique_parent_context

              subject { uniq_parent_inst }

              let(:base_specs) { [dept_bridge_base, dept_uniq_specie] }

              let(:vl_bridge) { Concepts::VeiledSpec.new(bridge_base) }
              let(:dept_uniq_parent) { dept_bridge_base.clone_with_replace(vl_bridge) }
              let(:dept_uniq_specie) { dept_methyl_on_bridge_base }
            end

            shared_context :raw_unique_reactant_context do
              let(:vl_unique_reactant) do
                Concepts::VeiledSpec.new(dept_unique_reactant.spec)
              end

              let(:uniq_reactant_inst) do
                Instances::UniqueReactant.new(generator, vl_unique_reactant)
              end

              [:cm, :cb, :cr, :cl].each do |keyname|
                let(keyname) { vl_unique_reactant.atom(keyname) }
              end
            end

            shared_context :unique_reactant_context do
              include_context :specie_instance_context
              include_context :raw_unique_reactant_context

              subject { uniq_reactant_inst }

              let(:base_specs) { [dept_bridge_base, dept_unique_reactant] }
              let(:dept_unique_reactant) { dept_methyl_on_bridge_base }
            end
          end

        end
      end
    end
  end
end
