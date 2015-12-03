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
            Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
              let(keyname) { first_spec.spec.atom(keyname) }
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
    SpecificSpec *specie1 = target();
    assert(specie1->type() == METHYL_ON_BRIDGE);
    Atom *atom = specie1->atom(0);
    assert(atom->is(#{role_cm}));
    atom->activate();
    assert(!atom->is(#{cm_iss}) && !atom->is(#{cm_sss}));
    if (atom->is(#{cm_i}))
    {
        atom->changeType(#{cm_is})
    }
    else
    {
        assert(atom->is(#{cm_is}));
        atom->changeType(#{cm_iss})
    }
    Finder::findAll(&atom, 1);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_deactivation }
              let(:first_spec) { dept_activated_methyl_on_bridge }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *specie1 = target();
    assert(specie1->type() == METHYL_ON_BRIDGE_CMs);
    Atom *atom = specie1->atom(0);
    assert(atom->is(#{role_cm}));
    atom->deactivate();
    if (atom->is(#{cm_is}))
    {
        atom->changeType(#{cm_i})
    }
    else if (atom->is(#{cm_iss}))
    {
        atom->changeType(#{cm_is})
    }
    else
    {
        assert(atom->is(#{cm_sss}));
        atom->changeType(#{cm_ss})
    }
    Finder::findAll(&atom, 1);
                CODE
              end
            end
          end
        end

      end
    end
  end
end
