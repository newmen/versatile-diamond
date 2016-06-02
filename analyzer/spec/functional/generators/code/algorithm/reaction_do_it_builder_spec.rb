require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionDoItBuilder, type: :algorithm, use: :atom_properties do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            bases = base_specs.dup
            specifics = specific_specs.dup

            append = -> spec { (spec.specific? ? specifics : bases) << spec }
            append[first_spec]
            append[second_spec] if respond_to?(:second_spec)

            stub_generator(
              base_specs: bases.uniq(&:name),
              specific_specs: specifics.uniq(&:name),
              typical_reactions: [typical_reaction])
          end

          let(:classifier) { generator.classifier }
          let(:builder) { described_class.new(generator, reaction) }
          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:species) do
            typical_reaction.surface_source.map { |s| generator.specie_class(s.name) }
          end

          def raw_props_idx(spec, keyname, str_opts)
            opts = convert_str_prop(str_opts)
            prop = Organizers::AtomProperties.new(spec, spec.spec.atom(keyname)) +
              Organizers::AtomProperties.raw(spec.spec.atom(keyname), **opts)
            classifier.index(prop)
          end

          shared_examples_for :check_do_it do
            it { expect(builder.build).to eq(do_it_algorithm) }
          end

          describe '#build' do
            USING_KEYNAMES = Support::RoleChecker::ANCHOR_KEYNAMES
            let_atoms_of(:'first_spec.spec', USING_KEYNAMES) do |keyname|
              let(:"role_#{keyname}") { role(first_spec, keyname) }
              let(:"snd_role_#{keyname}") { role(second_spec, keyname) }
            end

            let(:cm_sss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '***') }
            let(:cm_iss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i**') }
            let(:cm_ss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '**') }
            let(:cm_is) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i*') }
            let(:cm_i) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i') }

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_activation }
              let(:first_spec) { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_activated_methyl_on_bridge] }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *methylOnBridge1 = target();
    assert(methylOnBridge1->type() == METHYL_ON_BRIDGE);
    Atom *amorph1 = methylOnBridge1->atom(0);
    assert(amorph1->is(#{role_cm}));
    amorph1->activate();
    assert(!amorph1->is(#{cm_iss}) && !amorph1->is(#{cm_sss}));
    if (amorph1->is(#{cm_i}))
    {
        amorph1->changeType(#{cm_is});
    }
    else
    {
        assert(amorph1->is(#{cm_is}));
        amorph1->changeType(#{cm_iss});
    }
    Finder::findAll(&amorph1, 1);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_deactivation }
              let(:first_spec) { dept_activated_methyl_on_bridge }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *methylOnBridgeCMs1 = target();
    assert(methylOnBridgeCMs1->type() == METHYL_ON_BRIDGE_CMs);
    Atom *amorph1 = methylOnBridgeCMs1->atom(0);
    assert(amorph1->is(#{role_cm}));
    amorph1->deactivate();
    if (amorph1->is(#{cm_is}))
    {
        amorph1->changeType(#{cm_i});
    }
    else if (amorph1->is(#{cm_iss}))
    {
        amorph1->changeType(#{cm_is});
    }
    else
    {
        assert(amorph1->is(#{cm_sss}));
        amorph1->changeType(#{cm_ss});
    }
    Finder::findAll(&amorph1, 1);
                CODE
              end
            end
          end
        end

      end
    end
  end
end
