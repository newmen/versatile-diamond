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

          def convert_char_prop(char)
            if char == '*'
              [:danglings, Concepts::ActiveBond.property]
            elsif char == 'i'
              [:relevants, Concepts::Incoherent.property]
            end
          end

          def convert_str_prop(str)
            chars = str.scan(/./).group_by { |c| c }.map { |c, cs| [c, cs.size] }
            chars.each_with_object({}) do |(c, num), acc|
              key, value = convert_char_prop(c)
              acc[key] ||= []
              acc[key] += [value] * num
            end
          end

          def raw_props(spec, keyname, str_opts)
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

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_activation }
              let(:first_spec) { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_activated_methyl_on_bridge] }
              let(:cm_sss) { raw_props(dept_methyl_on_bridge_base, :cm, '***') }
              let(:cm_iss) { raw_props(dept_methyl_on_bridge_base, :cm, 'i**') }
              let(:cm_is) { raw_props(dept_methyl_on_bridge_base, :cm, 'i*') }
              let(:cm_i) { raw_props(dept_methyl_on_bridge_base, :cm, 'i') }
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
          end
        end

      end
    end
  end
end
