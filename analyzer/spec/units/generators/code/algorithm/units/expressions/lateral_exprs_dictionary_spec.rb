require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe LateralExprsDictionary, type: :algorithm do
          include_context :look_around_context
          include_context :small_activated_bridges_lateral_context

          subject { described_class.new(lateral_chunks.reaction) }

          let(:species_arr) { action_nodes.map(&:uniq_specie) }
          let(:reactant1) { species_arr.first }
          let(:reactant2) { species_arr.last }

          describe '#checkpoint! && #rollback!' do
            let(:proxy1) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy2) { Algorithm::Instances::OtherSideSpecie.new(reactant1) }
            let(:proxy3) { Algorithm::Instances::OtherSideSpecie.new(reactant2) }
            let(:proxies12) { [proxy1, proxy2] }
            it 'expect sidepiece species' do
              subject.make_chunks_first_item
              subject.make_chunks_next_item
              subject.make_chunks_list
              subject.make_iterator(:num)
              subject.make_chunks_counter
              expect(subject.counter_item('INDEX').code).to eq('counter[INDEX]')
              subject.make_specie_s(reactant1)
              subject.make_specie_s(proxy1)
              subject.checkpoint!
              expect(subject.var_of(:first_chunk).code).to eq('chunks[0]')
              expect(subject.var_of(:chunks_item).code).to eq('chunks[index++]')
              expect(subject.var_of(:chunks_list).code).to eq('chunks')
              expect(subject.var_of(:chunks_counter).code).to eq('counter')
              expect(subject.var_of(:counter_item)).to be_nil
              subject.make_specie_s(reactant2)
              subject.make_specie_s(proxy2)
              subject.make_specie_s(proxy3)
              expect(subject.same_vars(proxy1).map(&:instance)).to eq([proxy2])
              expect(subject.same_vars(proxy2).map(&:instance)).to eq([proxy1])
              expect(subject.same_vars(proxy3)).to be_empty
              expect(subject.different_vars(proxy1).map(&:instance)).to eq([proxy3])
              expect(subject.different_vars(proxy2).map(&:instance)).to eq([proxy3])
              expect(subject.different_vars(proxy3).map(&:instance)).to eq(proxies12)
              subject.rollback!
              expect(subject.same_vars(proxy1)).to be_empty
              expect(subject.same_vars(proxy3)).to be_empty
              expect(subject.different_vars(proxy1)).to be_empty
              expect(subject.var_of(:chunks_item)).not_to be_nil
            end
          end
        end

      end
    end
  end
end
