require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionDoItBuilder, type: :algorithm do
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

          shared_examples_for :check_do_it do
            it { expect(builder.build).to eq(do_it_algorithm) }
          end

          describe '#build' do
            Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
              let(keyname) { first_spec.spec.atom(keyname) }
              let(:"role_#{keyname}") { role(first_spec, keyname) }
              let(:"snd_role_#{keyname}") { role(second_spec, keyname) }
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_activation }
              let(:first_spec) { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_activated_methyl_on_bridge] }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *specie1 = target();
    assert(specie1->type() == METHYL_ON_DIMER_CLS_CMHIU);
    Atom *atom = specie1->atom(0);
    assert(atom->is(#{role_cm}));
    atom->activate();
    if (a->is(27)) a->changeType(13);
    else if (a->is(26)) a->changeType(27);
    else a->changeType(26);
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
