require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentReaction, type: :organizer do
      subject { dept_dimer_formation }
      let(:target) { dimer_formation }
      let(:ai_bridge) { activated_incoherent_bridge }
      let(:duplicate) do
        DependentTypicalReaction.new(dimer_formation.duplicate('dup'))
      end

      describe '#complexes' do
        it { expect(subject.complexes).to be_empty }
      end

      describe '#store_complex' do
        before { subject.store_complex(dept_end_lateral_df) }
        it { expect(subject.complexes).to eq([dept_end_lateral_df]) }
      end

      describe '#reaction' do
        it { subject.reaction == target }
      end

      describe '#parent' do
        it { expect(subject.parent).to be_nil }
      end

      describe '#name' do
        it { subject.name == target.name }
      end

      describe '#full_rate' do
        it { subject.full_rate == target.full_rate }
      end

      describe '#each_source' do
        it { expect(subject.each_source).to be_a(Enumerable) }

        it { expect(subject.each_source.to_a).
          to match_array([activated_bridge, ai_bridge]) }

        it { expect(dept_methyl_deactivation.each_source.to_a).
          to match_array([dm_source.first]) }
      end

      describe '#swap_source' do
        let(:source) { subject.each_source.to_a }
        let(:bridge_dup) { activated_bridge.dup }

        before(:each) { subject.swap_source(activated_bridge, bridge_dup) }

        it { expect(source).not_to include(activated_bridge) }
        it { expect(source).to include(bridge_dup) }
        it { expect(source).to include(ai_bridge) }
      end

      describe '#used_keynames_of' do
        it { expect(subject.used_keynames_of(activated_bridge)).to eq([:ct]) }
        it { expect(subject.used_keynames_of(ai_bridge)).to eq([:ct]) }
      end

      describe '#same?' do
        let(:lateral_subject) do
          DependentLateralReaction.new(
            target.lateral_duplicate('lateral', [on_middle]))
        end

        it { expect(subject.same?(duplicate)).to be_truthy }
        it { expect(duplicate.same?(subject)).to be_truthy }

        it { expect(subject.same?(lateral_subject)).to be_truthy }
        it { expect(lateral_subject.same?(subject)).to be_falsey }

        it { expect(subject.same?(dept_methyl_deactivation)).to be_falsey }
      end

      describe '#local?' do
        describe 'methyl activation' do
          subject { dept_methyl_activation }
          let(:ubiq_react) { dept_surface_activation }
          let(:term_cache) { make_cache([dept_adsorbed_h]) }
          let(:non_term_cache) do
            make_cache([dept_methyl_on_bridge, dept_hydrogen_ion])
          end

          before do
            ubiq_react.organize_dependencies!([subject], term_cache, non_term_cache)
          end

          it { expect(subject.local?).to be_truthy }
        end

        describe 'dimer formation' do
          it { expect(subject.local?).to be_falsey }
        end
      end

      describe '#formula' do
        let(:formula) { subject.formula }
        it { expect(formula).to match(/dimer\(.+? i\)/) }
        it { expect(formula).to match(/bridge\(ct: \*\)/) }
        it { expect(formula).to match(/bridge\(ct: \*, ct: i\)/) }
      end
    end

  end
end
