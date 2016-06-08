require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionDoItBuilder, type: :algorithm, use: :atom_properties do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:ubiquitous_reactions) { [] }
          let(:other_reactions) { [] }
          let(:generator) do
            bases = base_specs.dup
            specifics = specific_specs.dup

            append = -> spec { (spec.specific? ? specifics : bases) << spec }
            append[first_spec]
            append[second_spec] if respond_to?(:second_spec)

            stub_generator(
              base_specs: bases.uniq(&:name),
              specific_specs: specifics.uniq(&:name),
              ubiquitous_reactions: ubiquitous_reactions,
              typical_reactions: [typical_reaction] + other_reactions)
          end

          shared_context :with_ubiquitous do
            let(:ubiquitous_reactions) do
              [dept_surface_activation, dept_surface_deactivation]
            end
          end

          let(:classifier) { generator.classifier }
          let(:builder) { described_class.new(generator, reaction) }
          let(:reaction) { generator.reaction_class(typical_reaction.name) }
          let(:species) do
            typical_reaction.surface_source.map { |s| generator.specie_class(s.name) }
          end

          def raw_props_idx(spec, keyname, str_opts)
            classifier.index(raw_prop(spec, keyname, str_opts))
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

            let(:ct_ss) { raw_props_idx(dept_bridge_base, :ct, '**') }
            let(:ct_is) { raw_props_idx(dept_bridge_base, :ct, 'i*') }
            let(:ct_s) { raw_props_idx(dept_bridge_base, :ct, '*') }
            let(:ct_i) { raw_props_idx(dept_bridge_base, :ct, 'i') }
            let(:br_s) { raw_props_idx(dept_bridge_base, :cr, '*') }
            let(:br_i) { raw_props_idx(dept_bridge_base, :cr, 'i') }
            let(:br_m) { raw_props_idx(dept_methyl_on_right_bridge_base, :cr, '') }
            let(:cb_s) { raw_props_idx(dept_methyl_on_bridge_base, :cb, '*') }
            let(:cb_i) { raw_props_idx(dept_methyl_on_bridge_base, :cb, 'i') }
            let(:cd_s) { raw_props_idx(dept_dimer_base, :cr, '*') }
            let(:cd_i) { raw_props_idx(dept_dimer_base, :cr, 'i') }
            let(:cm_sss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '***') }
            let(:cm_iss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i**') }
            let(:cm_ss) { raw_props_idx(dept_methyl_on_bridge_base, :cm, '**') }
            let(:cm_is) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i*') }
            let(:cm_i) { raw_props_idx(dept_methyl_on_bridge_base, :cm, 'i') }
            let(:hm_ss) { raw_props_idx(dept_high_bridge_base, :cm, '**') }
            let(:hm_is) { raw_props_idx(dept_high_bridge_base, :cm, 'i*') }
            let(:hm_i) { raw_props_idx(dept_high_bridge_base, :cm, 'i') }
            let(:cv_s) { raw_props_idx(dept_vinyl_on_bridge_base, :c1, '*') }
            let(:cv_i) { raw_props_idx(dept_vinyl_on_bridge_base, :c1, 'i') }
            let(:cw_ss) { raw_props_idx(dept_vinyl_on_bridge_base, :c2, '**') }
            let(:cw_is) { raw_props_idx(dept_vinyl_on_bridge_base, :c2, 'i*') }
            let(:cw_i) { raw_props_idx(dept_vinyl_on_bridge_base, :c2, 'i') }
            let(:sm_ss) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, '**') }
            let(:sm_is) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, 'i*') }
            let(:sm_i) { raw_props_idx(dept_cross_bridge_on_bridges_base, :cm, 'i') }

            describe 'methyl activation' do
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
    assert(!amorph1->is(#{cm_sss}));
    if (amorph1->is(#{cm_iss}))
    {
        amorph1->changeType(#{cm_sss});
    }
    else if (amorph1->is(#{cm_is}))
    {
        amorph1->changeType(#{cm_iss});
    }
    else
    {
        assert(amorph1->is(#{cm_i}));
        amorph1->changeType(#{cm_is});
    }
    Finder::findAll(&amorph1, 1);
                CODE
              end

              it_behaves_like :check_do_it
              it_behaves_like :check_do_it do
                include_context :with_ubiquitous
              end
            end

            describe 'methyl deactivation' do
              let(:typical_reaction) { dept_methyl_deactivation }
              let(:first_spec) { dept_activated_methyl_on_bridge }

              it_behaves_like :check_do_it do
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *methylOnBridgeCMs1 = target();
    assert(methylOnBridgeCMs1->type() == METHYL_ON_BRIDGE_CMs);
    Atom *amorph1 = methylOnBridgeCMs1->atom(0);
    assert(amorph1->is(#{role_cm}));
    amorph1->deactivate();
    amorph1->changeType(#{cm_i});
    Finder::findAll(&amorph1, 1);
                  CODE
                end
              end

              describe 'all states' do
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *methylOnBridgeCMs1 = target();
    assert(methylOnBridgeCMs1->type() == METHYL_ON_BRIDGE_CMs);
    Atom *amorph1 = methylOnBridgeCMs1->atom(0);
    assert(amorph1->is(#{role_cm}));
    amorph1->deactivate();
    if (amorph1->is(#{cm_sss}))
    {
        amorph1->changeType(#{cm_ss});
    }
    else if (amorph1->is(#{cm_iss}))
    {
        amorph1->changeType(#{cm_is});
    }
    else
    {
        assert(amorph1->is(#{cm_is}));
        amorph1->changeType(#{cm_i});
    }
    Finder::findAll(&amorph1, 1);
                  CODE
                end

                it_behaves_like :check_do_it do
                  include_context :with_ubiquitous
                end

                it_behaves_like :check_do_it do
                  let(:other_reactions) { [dept_methyl_activation] }
                end
              end
            end

            describe 'methyl adsorption' do
              let(:typical_reaction) { dept_methyl_adsorption }
              let(:first_spec) { dept_activated_bridge }

              it_behaves_like :check_do_it do
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *bridgeCTs1 = target();
    assert(bridgeCTs1->type() == BRIDGE_CTs);
    AtomBuilder builder;
    Atom *atoms1[2] = { bridgeCTs1->atom(0), builder.buildC(#{cm_i}, 1) };
    assert(atoms1[0]->is(#{ct_s}));
    Handbook::amorph().insert(atoms1[1]);
    atoms1[0]->bondWith(atoms1[1]);
    atoms1[0]->changeType(#{cb_i});
    Finder::findAll(atoms1, 2);
                  CODE
                end
              end

              it_behaves_like :check_do_it do
                include_context :with_ubiquitous
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *bridgeCTs1 = target();
    assert(bridgeCTs1->type() == BRIDGE_CTs);
    AtomBuilder builder;
    Atom *atoms1[2] = { bridgeCTs1->atom(0), builder.buildC(#{cm_i}, 1) };
    assert(atoms1[0]->is(#{ct_s}));
    Handbook::amorph().insert(atoms1[1]);
    atoms1[0]->bondWith(atoms1[1]);
    assert(!atoms1[0]->is(#{cb_s}));
    if (atoms1[0]->is(#{br_s}))
    {
        atoms1[0]->changeType(#{br_m});
    }
    else if (atoms1[0]->is(#{ct_ss}))
    {
        atoms1[0]->changeType(#{cb_s});
    }
    else
    {
        assert(atoms1[0]->is(#{ct_is}));
        atoms1[0]->changeType(#{cb_i});
    }
    Finder::findAll(atoms1, 2);
                  CODE
                end
              end
            end

            describe 'vinyl adsorption' do
              let(:typical_reaction) { dept_vinyl_adsorption }
              let(:first_spec) { dept_activated_bridge }

              it_behaves_like :check_do_it do
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *bridgeCTs1 = target();
    assert(bridgeCTs1->type() == BRIDGE_CTs);
    AtomBuilder builder;
    Atom *atoms1[3] = { bridgeCTs1->atom(0), builder.buildC(#{cv_i}, 3), builder.buildC(#{cw_i}, 2) };
    assert(atoms1[0]->is(#{ct_s}));
    Handbook::amorph().insert(atoms1[1]);
    Handbook::amorph().insert(atoms1[2]);
    atoms1[0]->bondWith(atoms1[1]);
    atoms1[1]->bondWith(atoms1[2]);
    atoms1[1]->bondWith(atoms1[2]);
    atoms1[0]->changeType(#{cb_i});
    Finder::findAll(atoms1, 3);
                  CODE
                end
              end

              it_behaves_like :check_do_it do
                include_context :with_ubiquitous
                let(:do_it_algorithm) do
                  <<-CODE
    SpecificSpec *bridgeCTs1 = target();
    assert(bridgeCTs1->type() == BRIDGE_CTs);
    AtomBuilder builder;
    Atom *atoms1[3] = { bridgeCTs1->atom(0), builder.buildC(#{cv_i}, 3), builder.buildC(#{cw_i}, 2) };
    assert(atoms1[0]->is(#{ct_s}));
    Handbook::amorph().insert(atoms1[1]);
    Handbook::amorph().insert(atoms1[2]);
    atoms1[0]->bondWith(atoms1[1]);
    atoms1[1]->bondWith(atoms1[2]);
    atoms1[1]->bondWith(atoms1[2]);
    assert(!atoms1[0]->is(#{cb_s}));
    if (atoms1[0]->is(#{br_s}))
    {
        atoms1[0]->changeType(#{br_m});
    }
    else if (atoms1[0]->is(#{ct_ss}))
    {
        atoms1[0]->changeType(#{cb_s});
    }
    else
    {
        assert(atoms1[0]->is(#{ct_is}));
        atoms1[0]->changeType(#{cb_i});
    }
    Finder::findAll(atoms1, 3);
                  CODE
                end
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_desorption }
              let(:first_spec) { dept_incoherent_methyl_on_bridge }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *methylOnBridgeCMi1 = target();
    assert(methylOnBridgeCMi1->type() == METHYL_ON_BRIDGE_CMi);
    Atom *atoms1[2] = { methylOnBridgeCMi1->atom(1), methylOnBridgeCMi1->atom(0) };
    assert(atoms1[0]->is(#{role_cb}));
    assert(atoms1[1]->is(#{cm_i}));
    Handbook::amorph().erase(atoms1[1]);
    atoms1[1]->unbondFrom(atoms1[0]);
    if (atoms1[0]->is(#{cb_s}))
    {
        atoms1[0]->changeType(#{ct_ss});
    }
    else
    {
        assert(atoms1[0]->is(#{cb_i}));
        atoms1[0]->changeType(#{ct_is});
    }
    Handbook::scavenger().markAtom(atoms1[1]);
    Finder::findAll(&atoms1[0], 1);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_vinyl_desorption }
              let(:first_spec) { dept_vinyl_on_bridge_base }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *vinylOnBridgeC1iC2i1 = target();
    assert(vinylOnBridgeC1iC2i1->type() == VINYL_ON_BRIDGE_C1i_C2i);
    Atom *atoms1[3] = { vinylOnBridgeC1iC2i1->atom(2), vinylOnBridgeC1iC2i1->atom(0), vinylOnBridgeC1iC2i1->atom(1) };
    assert(atoms1[0]->is(#{role_cb}));
    assert(atoms1[1]->is(#{cv_i}));
    assert(atoms1[2]->is(#{cw_i}));
    Handbook::amorph().erase(atoms1[1]);
    Handbook::amorph().erase(atoms1[2]);
    atoms1[1]->unbondFrom(atoms1[0]);
    if (atoms1[0]->is(#{cb_s}))
    {
        atoms1[0]->changeType(#{ct_ss});
    }
    else
    {
        assert(atoms1[0]->is(#{cb_i}));
        atoms1[0]->changeType(#{ct_is});
    }
    Handbook::scavenger().markAtom(atoms1[1]);
    Handbook::scavenger().markAtom(atoms1[2]);
    Finder::findAll(&atoms1[0], 1);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_sierpinski_drop }
              let(:first_spec) { dept_cross_bridge_on_bridges_base }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *crossBridgeOnBridges1 = target();
    assert(crossBridgeOnBridges1->type() == CROSS_BRIDGE_ON_BRIDGES);
    Atom *atoms1[2] = { crossBridgeOnBridges1->atom(5), crossBridgeOnBridges1->atom(0) };
    assert(atoms1[0]->is(#{role_ctr}));
    assert(atoms1[1]->is(#{role_cm}));
    atoms1[0]->unbondFrom(atoms1[1]);
    atoms1[0]->changeType(#{ct_is});
    atoms1[1]->changeType(#{cm_is});
    Finder::findAll(atoms1, 2);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_sierpinski_formation }
              let(:first_spec) { dept_activated_methyl_on_bridge }
              let(:second_spec) { dept_activated_bridge }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *species1[2] = { target(0), target(1) };
    assert(species1[0]->type() == BRIDGE_CTs);
    assert(species1[1]->type() == METHYL_ON_BRIDGE_CMs);
    Atom *atoms1[2] = { species1[0]->atom(0), species1[1]->atom(0) };
    assert(atoms1[0]->is(#{snd_role_ct}));
    assert(atoms1[1]->is(#{role_cm}));
    atoms1[0]->bondWith(atoms1[1]);
    assert(!atoms1[0]->is(#{br_s}) && !atoms1[0]->is(#{cb_s}));
    if (atoms1[0]->is(#{ct_ss}))
    {
        atoms1[0]->changeType(#{cb_s});
    }
    else
    {
        assert(atoms1[0]->is(#{ct_is}));
        atoms1[0]->changeType(#{cb_i});
    }
    assert(!atoms1[1]->is(#{sm_is}) && !atoms1[1]->is(#{sm_ss}));
    if (atoms1[1]->is(#{cm_sss}))
    {
        atoms1[1]->changeType(#{sm_ss});
    }
    else if (atoms1[1]->is(#{cm_iss}))
    {
        atoms1[1]->changeType(#{sm_is});
    }
    else
    {
        assert(atoms1[1]->is(#{cm_is}));
        atoms1[1]->changeType(#{sm_i});
    }
    Finder::findAll(atoms1, 2);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_incoherent_dimer_drop }
              let(:first_spec) { dept_twise_incoherent_dimer }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *dimerCLiCRi1 = target();
    assert(dimerCLiCRi1->type() == DIMER_CLi_CRi);
    Atom *atoms1[2] = { dimerCLiCRi1->atom(3), dimerCLiCRi1->atom(0) };
    assert(atoms1[0]->is(#{role_cr}));
    assert(atoms1[1]->is(#{role_cr}));
    atoms1[0]->unbondFrom(atoms1[1]);
    Finder::findAll(atoms1, 2);
                CODE
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_dimer_formation }
              let(:first_spec) { dept_activated_incoherent_bridge }
              let(:second_spec) { dept_activated_bridge }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *species1[2] = { target(0), target(1) };
    assert(species1[0]->type() == BRIDGE_CTs);
    assert(species1[1]->type() == BRIDGE_CTsi);
    Atom *atoms1[2] = { species1[1]->atom(0), species1[0]->atom(0) };
    assert(atoms1[0]->is(#{role_ct}));
    assert(atoms1[1]->is(#{snd_role_ct}));
    atoms1[0]->bondWith(atoms1[1]);
    assert(!atoms1[0]->is(#{ct_ss}));
    assert(!atoms1[1]->is(#{br_s}) && !atoms1[1]->is(#{cd_s}));
    if (atoms1[1]->is(#{ct_ss}))
    {
        atoms1[1]->changeType(#{cd_s});
    }
    else
    {
        assert(atoms1[1]->is(#{ct_is}));
        atoms1[1]->changeType(#{cd_i});
    }
    Finder::findAll(atoms1, 2);
                CODE
              end
            end

            describe 'intermediate migration down formation' do
              let(:first_spec) { dept_activated_bridge }
              let(:second_spec) { dept_activated_methyl_on_dimer }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *species1[2] = { target(0), target(1) };
    assert(species1[0]->type() == BRIDGE_CTs);
    assert(species1[1]->type() == METHYL_ON_DIMER_CMs);
    Atom *atoms1[2] = { species1[0]->atom(0), species1[1]->atom(0) };
    assert(atoms1[0]->is(#{role_ct}));
    assert(atoms1[1]->is(#{snd_role_cm}));
    atoms1[0]->bondWith(atoms1[1]);
    assert(!atoms1[0]->is(#{br_s}) && !atoms1[0]->is(#{cb_s}));
    if (atoms1[0]->is(#{cd_s}))
    {
        atoms1[0]->changeType(#{snd_role_cr});
    }
    else if (atoms1[0]->is(#{ct_ss}))
    {
        atoms1[0]->changeType(#{cb_s});
    }
    else
    {
        assert(atoms1[0]->is(#{ct_is}));
        atoms1[0]->changeType(#{cb_i});
    }
    assert(!atoms1[1]->is(#{sm_is}) && !atoms1[1]->is(#{sm_ss}));
    if (atoms1[1]->is(#{cm_sss}))
    {
        atoms1[1]->changeType(#{sm_ss});
    }
    else if (atoms1[1]->is(#{cm_iss}))
    {
        atoms1[1]->changeType(#{sm_is});
    }
    else
    {
        assert(atoms1[1]->is(#{cm_is}));
        atoms1[1]->changeType(#{sm_i});
    }
    Finder::findAll(atoms1, 2);
                CODE
              end

              it_behaves_like :check_do_it do
                let(:typical_reaction) { dept_intermed_migr_dc_formation }
              end

              it_behaves_like :check_do_it do
                let(:typical_reaction) { dept_intermed_migr_dh_formation }
              end

              it_behaves_like :check_do_it do
                let(:typical_reaction) { dept_intermed_migr_df_formation }
              end
            end

            it_behaves_like :check_do_it do
              let(:typical_reaction) { dept_methyl_incorporation }
              let(:first_spec) { dept_activated_methyl_on_bridge }
              let(:second_spec) { dept_activated_dimer }
              let(:base_specs) { [dept_bridge_base] }
              let(:do_it_algorithm) do
                <<-CODE
    SpecificSpec *species1[2] = { target(0), target(1) };
    assert(species1[0]->type() == METHYL_ON_BRIDGE_CMs);
    assert(species1[1]->type() == DIMER_CRs);
    Atom *atoms1[4] = { species1[1]->atom(0), species1[1]->atom(3), species1[0]->atom(1), species1[0]->atom(0) };
    assert(atoms1[0]->is(#{snd_role_cr}));
    assert(atoms1[1]->is(#{snd_role_cl}));
    assert(atoms1[2]->is(#{role_cb}));
    assert(atoms1[3]->is(#{role_cm}));
    Handbook::amorph().erase(atoms1[3]);
    crystalBy(atoms1[1])->insert(atoms1[3], Diamond::front_110_at(atoms1[1], atoms1[0]));
    atoms1[0]->unbondFrom(atoms1[1]);
    atoms1[0]->deactivate();
    atoms1[3]->activate();
    atoms1[0]->bondWith(atoms1[3]);
    atoms1[1]->bondWith(atoms1[3]);
    assert(!atoms1[1]->is(#{cd_s}));
    atoms1[0]->changeType(#{br_i});
    atoms1[1]->changeType(#{br_i});
    if (atoms1[2]->is(#{br_s}))
    {
        atoms1[2]->changeType(#{cd_s});
    }
    else
    {
        assert(atoms1[2]->is(#{br_i}));
        atoms1[2]->changeType(#{cd_i});
    }
    assert(!atoms1[3]->is(#{ct_ss}));
    if (atoms1[3]->is(#{cm_iss}))
    {
        atoms1[3]->changeType(#{cd_s});
    }
    else
    {
        assert(atoms1[3]->is(#{cm_is}));
        atoms1[3]->changeType(#{cd_i});
    }
    Finder::findAll(atoms1, 4);
                CODE
              end
            end
          end
        end

      end
    end
  end
end
