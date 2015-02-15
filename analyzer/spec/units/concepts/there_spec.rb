require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe There do
      let(:ab) { df_source.first }
      let(:aib) { df_source.last }
      let(:aib_dup) { activated_incoherent_bridge.dup }

      shared_examples_for :check_links_graph do
        it { expect(subject.links).to match_graph(links) }
      end

      describe '#dup' do
        subject { on_end.dup }
        it { should_not == on_end }
        it { expect(subject.links).to eq(on_end.links) }
        it { expect(subject.links.object_id).not_to eq(on_end.links.object_id) }

        describe "target swapping doesn't change duplicate" do
          before { subject.swap_target(aib, aib_dup) }
          it { expect(subject.target_specs).not_to eq(on_end.target_specs) }
        end
      end

      describe '#description' do
        it { expect(on_end.description).to eq(at_end.description) }
      end

      describe '#target_specs' do
        it { expect(on_end.target_specs).to match_array([ab, aib]) }
        it { expect(on_middle.target_specs).to match_array([ab, aib]) }
        it { expect(there_methyl.target_specs).to eq([ab]) }
      end

      describe '#env_specs' do
        it { expect(on_end.env_specs).to eq([dimer]) }
        it { expect(on_middle.env_specs).to match_array([dimer, dimer_dup]) }
        it { expect(there_methyl.env_specs).to eq([methyl_on_bridge]) }
      end

      describe '#links' do
        it_behaves_like :check_links_graph do
          subject { on_end }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross]
              ],
              [aib, aib.atom(:ct)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross]
              ]
            }
          end
        end

        it_behaves_like :check_links_graph do
          subject { on_middle }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cl)], position_100_cross],
              ],
              [aib, aib.atom(:ct)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cr)], position_100_cross],
              ]
            }
          end
        end

        it_behaves_like :check_links_graph do
          subject { there_methyl }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [
                [[methyl_on_bridge, methyl_on_bridge.atom(:cb)], position_100_front]
              ]
            }
          end
        end
      end

      it_behaves_like :check_specs_after_swap_source do
        subject { on_end }
        let(:method) { :env_specs }
      end

      describe '#use_similar_source?' do
        subject { on_end }
        it { expect(subject.use_similar_source?(dimer)).to be_truthy }
        it { expect(subject.use_similar_source?(dimer.dup)).to be_falsey}
        it { expect(subject.use_similar_source?(bridge_base)).to be_falsey }

        it { expect(subject.use_similar_source?(ab)).to be_truthy }
        it { expect(subject.use_similar_source?(ab.dup)).to be_falsey }
      end

      describe '#swap_source' do
        it_behaves_like :check_links_graph do
          subject { on_end }
          before { subject.swap_source(dimer, d_dup) }
          let(:d_dup) { dimer.dup }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [[[d_dup, d_dup.atom(:cl)], position_100_cross]],
              [aib, aib.atom(:ct)] => [[[d_dup, d_dup.atom(:cr)], position_100_cross]]
            }
          end
        end
      end

      describe '#swap_target' do
        it_behaves_like :check_links_graph do
          subject { on_end }
          before { subject.swap_target(aib, aib_dup) }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross]
              ],
              [aib_dup, aib_dup.atom(:ct)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross]
              ]
            }
          end
        end
      end

      describe '#used_atoms_of' do
        let(:atoms) { [:cr, :cl].map { |kn| dimer.atom(kn) } }

        describe 'on end' do
          it { expect(on_end.used_atoms_of(dimer)).to match_array(atoms) }
        end

        describe 'on middle' do
          it { expect(on_middle.used_atoms_of(dimer)).to match_array(atoms) }
        end

        describe 'there methyl' do
          let(:spec) { methyl_on_bridge }
          let(:atoms) { [spec.atom(:cb)] }
          it { expect(there_methyl.used_atoms_of(spec)).to match_array(atoms) }
        end
      end

      describe '#same?' do
        let(:reverse_end) { end_lateral_df.reverse.theres.first }
        let(:same) do
          at_end.concretize(
            two: [dimer, dimer.atom(:cl)], one: [dimer, dimer.atom(:cr)])
        end

        it { expect(reverse_end.same?(same)).to be_falsey }
        it { expect(same.same?(reverse_end)).to be_falsey }

        it { expect(on_end.same?(same)).to be_falsey }
        it { expect(same.same?(on_end)).to be_falsey }

        it { expect(on_end.same?(on_middle)).to be_falsey }
        it { expect(on_middle.same?(on_end)).to be_falsey }
        it { expect(on_end.same?(there_methyl)).to be_falsey }
      end

      describe '#same_own_positions?' do
        it { expect(on_end.same_own_positions?(on_middle)).to be_truthy }
        it { expect(on_middle.same_own_positions?(on_end)).to be_truthy }

        it { expect(on_end.same_own_positions?(there_methyl)).to be_falsey }
        it { expect(there_methyl.same_own_positions?(on_end)).to be_falsey }
      end
    end

  end
end
