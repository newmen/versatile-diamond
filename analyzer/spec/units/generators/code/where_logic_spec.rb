require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe WhereLogic, type: :code do
        let(:generator) { stub_generator }

        shared_examples_for :use_at_end do
          %i(cl cr).each do |kn|
            let(kn) { dimer.atom(kn) }
          end

          subject { described_class.new(generator, at_end) }
        end

        shared_examples_for :use_near_methyl do
          let(:cb) { methyl_on_bridge.atom(:cb) }
          subject { described_class.new(generator, near_methyl) }
        end

        describe '#signature' do
          shared_examples_for :check_signature do
            it { expect(subject.signature).to eq(signature) }
          end

          it_behaves_like :use_at_end do
            it_behaves_like :check_signature do
              let(:signature) { 'atEnd(Atom **atoms, const L &lambda)' }
            end
          end

          it_behaves_like :use_near_methyl do
            it_behaves_like :check_signature do
              let(:signature) { 'nearMethyl(Atom *atom, const L &lambda)' }
            end
          end
        end

        describe '#clean_links' do
          shared_examples_for :check_clean_links do
            it { expect(subject.clean_links).to match_graph(clean_links) }
          end

          it_behaves_like :use_at_end do
            it_behaves_like :check_clean_links do
              let(:clean_links) do
                {
                  :one => [[[dimer, cl], position_100_cross]],
                  :two => [[[dimer, cr], position_100_cross]],
                  [dimer, cl] => [[:one, position_100_cross]],
                  [dimer, cr] => [[:two, position_100_cross]]
                }
              end
            end
          end

          it_behaves_like :use_near_methyl do
            it_behaves_like :check_clean_links do
              let(:clean_links) do
                {
                  :target => [[[methyl_on_bridge, cb], position_100_front]],
                  [methyl_on_bridge, cb] => [[:target, position_100_front]]
                }
              end
            end
          end
        end

        describe '#links' do
          shared_examples_for :check_links do
            it { expect(subject.links).to match_graph(links) }
          end

          it_behaves_like :use_at_end do
            it_behaves_like :check_links do
              let(:links) do
                {
                  :one => [[[dimer, cl], position_100_cross]],
                  :two => [[[dimer, cr], position_100_cross]],
                  [dimer, cl] => [
                    [:one, position_100_cross], [[dimer, cr], bond_100_front]
                  ],
                  [dimer, cr] => [
                    [:two, position_100_cross], [[dimer, cl], bond_100_front]
                  ]
                }
              end
            end
          end

          it_behaves_like :use_near_methyl do
            it_behaves_like :check_links do
              let(:links) do
                {
                  :target => [[[methyl_on_bridge, cb], position_100_front]],
                  [methyl_on_bridge, cb] => [[:target, position_100_front]]
                }
              end
            end
          end
        end
      end

    end
  end
end
