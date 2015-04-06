require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentThere, type: :organizer do
      subject { described_class.new(there_methyl) }

      describe '#description' do
        it { expect(subject.description).to eq(there_methyl.description) }
      end

      describe '#links' do
        shared_examples_for :check_links do
          it { expect(dept_there.links).to match_graph(links) }
        end

        it_behaves_like :check_links do
          let(:dept_there) { dept_on_end }
          let(:ab) { df_source.first }
          let(:aib) { df_source.last }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [[[dimer, dimer.atom(:cl)], position_100_cross]],
              [aib, aib.atom(:ct)] => [[[dimer, dimer.atom(:cr)], position_100_cross]],
              [dimer, dimer.atom(:cr)] => [
                [[aib, aib.atom(:ct)], position_100_cross],
                [[dimer, dimer.atom(:cl)], bond_100_front],
                [[dimer, dimer.atom(:crb)], bond_110_cross],
                [[dimer, dimer.atom(:_cr0)], bond_110_cross]
              ],
              [dimer, dimer.atom(:crb)] => [
                [[dimer, dimer.atom(:cr)], bond_110_front],
                [[dimer, dimer.atom(:_cr0)], position_100_front]
              ],
              [dimer, dimer.atom(:_cr0)] => [
                [[dimer, dimer.atom(:cr)], bond_110_front],
                [[dimer, dimer.atom(:crb)], position_100_front]
              ],
              [dimer, dimer.atom(:cl)] => [
                [[ab, ab.atom(:ct)], position_100_cross],
                [[dimer, dimer.atom(:cr)], bond_100_front],
                [[dimer, dimer.atom(:clb)], bond_110_cross],
                [[dimer, dimer.atom(:_cr1)], bond_110_cross]
              ],
              [dimer, dimer.atom(:clb)] => [
                [[dimer, dimer.atom(:cl)], bond_110_front],
                [[dimer, dimer.atom(:_cr1)], position_100_front]
              ],
              [dimer, dimer.atom(:_cr1)] => [
                [[dimer, dimer.atom(:cl)], bond_110_front],
                [[dimer, dimer.atom(:clb)], position_100_front],
              ],
            }
          end
        end

        it_behaves_like :check_links do
          let(:dept_there) { dept_on_middle }
          let(:ab) { df_source.first }
          let(:aib) { df_source.last }
          let(:links) do
            {
              [ab, ab.atom(:ct)] => [
                [[dimer, dimer.atom(:cl)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cl)], position_100_cross],
              ],
              [aib, aib.atom(:ct)] => [
                [[dimer, dimer.atom(:cr)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cr)], position_100_cross],
              ],
              [dimer, dimer.atom(:cr)] => [
                [[aib, aib.atom(:ct)], position_100_cross],
                [[dimer, dimer.atom(:cl)], bond_100_front],
                [[dimer, dimer.atom(:crb)], bond_110_cross],
                [[dimer, dimer.atom(:_cr0)], bond_110_cross]
              ],
              [dimer, dimer.atom(:crb)] => [
                [[dimer, dimer.atom(:cr)], bond_110_front],
                [[dimer, dimer.atom(:_cr0)], position_100_front]
              ],
              [dimer, dimer.atom(:_cr0)] => [
                [[dimer, dimer.atom(:cr)], bond_110_front],
                [[dimer, dimer.atom(:crb)], position_100_front]
              ],
              [dimer, dimer.atom(:cl)] => [
                [[ab, ab.atom(:ct)], position_100_cross],
                [[dimer, dimer.atom(:cr)], bond_100_front],
                [[dimer, dimer.atom(:clb)], bond_110_cross],
                [[dimer, dimer.atom(:_cr1)], bond_110_cross]
              ],
              [dimer, dimer.atom(:clb)] => [
                [[dimer, dimer.atom(:cl)], bond_110_front],
                [[dimer, dimer.atom(:_cr1)], position_100_front]
              ],
              [dimer, dimer.atom(:_cr1)] => [
                [[dimer, dimer.atom(:cl)], bond_110_front],
                [[dimer, dimer.atom(:clb)], position_100_front],
              ],
              [dimer_dup, dimer_dup.atom(:cr)] => [
                [[aib, aib.atom(:ct)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cl)], bond_100_front],
                [[dimer_dup, dimer_dup.atom(:crb)], bond_110_cross],
                [[dimer_dup, dimer_dup.atom(:_cr0)], bond_110_cross]
              ],
              [dimer_dup, dimer_dup.atom(:crb)] => [
                [[dimer_dup, dimer_dup.atom(:cr)], bond_110_front],
                [[dimer_dup, dimer_dup.atom(:_cr0)], position_100_front]
              ],
              [dimer_dup, dimer_dup.atom(:_cr0)] => [
                [[dimer_dup, dimer_dup.atom(:cr)], bond_110_front],
                [[dimer_dup, dimer_dup.atom(:crb)], position_100_front]
              ],
              [dimer_dup, dimer_dup.atom(:cl)] => [
                [[ab, ab.atom(:ct)], position_100_cross],
                [[dimer_dup, dimer_dup.atom(:cr)], bond_100_front],
                [[dimer_dup, dimer_dup.atom(:clb)], bond_110_cross],
                [[dimer_dup, dimer_dup.atom(:_cr1)], bond_110_cross]
              ],
              [dimer_dup, dimer_dup.atom(:clb)] => [
                [[dimer_dup, dimer_dup.atom(:cl)], bond_110_front],
                [[dimer_dup, dimer_dup.atom(:_cr1)], position_100_front]
              ],
              [dimer_dup, dimer_dup.atom(:_cr1)] => [
                [[dimer_dup, dimer_dup.atom(:cl)], bond_110_front],
                [[dimer_dup, dimer_dup.atom(:clb)], position_100_front],
              ],
            }
          end
        end
      end

      describe '#each_source' do
        it { expect(subject.each_source).to be_a(Enumerator) }
        it { expect(subject.each_source.to_a).to eq([methyl_on_bridge]) }
      end

      describe '#swap_source' do
        let(:mob_dup) { methyl_on_bridge.dup }
        before { subject.swap_source(methyl_on_bridge, mob_dup) }
        it { expect(subject.each_source.to_a).to eq([mob_dup]) }
      end

      describe '#used_atoms_of' do
        let(:atoms) { [methyl_on_bridge.atom(:cb)] }
        it { expect(subject.used_atoms_of(dept_methyl_on_bridge)).to eq(atoms) }
      end

      describe '#targets' do
        shared_examples_for :check_targets do
          let(:ab) { dept_reaction.reaction.source.first }
          let(:aib) { dept_reaction.reaction.source.last }
          let(:targets) { [[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
          it { expect(dept_reaction.theres.first.targets).to match_array(targets) }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_end_lateral_df }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_middle_lateral_df }
        end
      end
    end

  end
end
