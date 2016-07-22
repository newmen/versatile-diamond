require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        describe ReactionApplyingDictionary, type: :algorithm do
          include_context :dimer_formation_context

          subject { described_class.new(typical_reaction) }

          describe '#checkpoint! && #rollback!' do
            it 'expect sidepiece species' do
              subject.make_atoms_builder
              subject.checkpoint!
              expect(subject.var_of(:atoms_builder).code).to eq('builder')
              subject.rollback!(forget: true)
              expect(subject.var_of(:atoms_builder)).not_to be_nil
              subject.rollback!(forget: true)
              expect(subject.var_of(:atoms_builder)).to be_nil
            end
          end

          describe '#make_atoms_builder' do
            describe 'not defined' do
              it { expect(subject.var_of(:atoms_builder)).to be_nil }
            end

            describe 'defined one time' do
              before { builder }
              let(:builder) { subject.make_atoms_builder }
              it { expect(subject.var_of(:atoms_builder)).to eq(builder) }
              it { expect(subject.make_atoms_builder).to equal(builder) }
            end

            describe 'defined after rollback' do
              before do
                builder # define and cache
                subject.rollback!
              end
              let(:builder) { subject.make_atoms_builder } # cached
              it { expect(subject.make_atoms_builder).not_to equal(builder) }
            end
          end
        end

      end
    end
  end
end
