require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Chest do
      class Concept < Concepts::Named; end

      let(:concept) { Concept.new(:some) }
      let(:o_dups) { [Concept.new(:some)] }
      let(:o_another) { [Concept.new(:another)] }
      let(:m_dups) { [Concept.new(:first), Concept.new(:some)] }
      let(:m_another) { [Concept.new(:first), Concept.new(:second)] }

      let(:keyname_error) { Chest::KeyNameError }

      describe '#store' do
        it { expect(Chest.store(concept)).to eq(Chest) }

        shared_examples_for 'check duplication' do
          describe 'duplication' do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*dups.map(&:dup)) }.
              to raise_error keyname_error }
          end

          describe 'another concept' do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*another.map(&:dup)) }.
              to_not raise_error }
          end
        end

        it_behaves_like 'check duplication' do
          let(:dups) { o_dups }
          let(:another) { o_another }
        end

        it_behaves_like 'check duplication' do
          let(:dups) { m_dups }
          let(:another) { m_another }
        end
      end

      describe '#atom' do
        before { Chest.store(c) }
        it { expect(Chest.atom(:C)).not_to eq(c) }
      end

      describe '#spec' do
        describe 'gas spec' do
          before { Chest.store(methane_base) }
          it { expect(Chest.spec(:methane)).to eq(methane_base) }
        end

        describe 'surface spec' do
          before { Chest.store(bridge_base) }
          it { expect(Chest.spec(:bridge)).to eq(bridge_base) }
        end
      end

      describe '#there' do
        let(:lateral) { dimers_row.make_lateral(one: 1, two: 2) }
        before(:each) do
          Chest.store(dimers_row, at_end)
          Chest.store(dimer_formation, lateral)
        end

        it { expect(Chest.there(dimer_formation, :at_end)).
          to be_a(Concepts::There) }
        it { expect { Chest.there(dimer_formation, :wrong) }.
          to raise_error keyname_error }

        describe 'has many wheres' do
          let(:env) do
            e = Concepts::Environment.new(:some)
            e.targets = [:first, :second]; e
          end
          let(:another_lateral) { env.make_lateral(first: 'f', second: 's') }

          before do
            Chest.store(env, at_end)
            Chest.store(dimer_formation, another_lateral)
          end

          it { expect { Chest.there(dimer_formation, :at_end) }.
            to raise_error keyname_error }
        end
      end

      describe '#method_missing' do
        shared_examples_for 'store and get concept' do
          before { Chest.store(*concepts) }
          it { expect(Chest.concept(*concepts.map(&:name))).
            to eq(concepts.last) }
        end

        it_behaves_like 'store and get concept' do
          let(:concepts) { o_dups }
        end

        it_behaves_like 'store and get concept' do
          let(:concepts) { m_dups }
        end

        it 'wrong key of concept' do
          expect { Chest.wrong(:not_important) }.to raise_error keyname_error
        end

        it 'wrong name of concept' do
          Chest.store(concept)
          expect { Chest.concept(:wrong) }.to raise_error keyname_error
        end
      end

      describe '#has?' do
        before(:each) { Chest.store(concept) }
        it { expect(Chest.has?(concept)).to be_true }
        it { expect(Chest.has?(Concept.new(:wrong))).to be_false }
      end

      describe '#all' do
        before(:each) do
          Chest.store(methane_base)
          Chest.store(bridge_base)
        end

        it { expect(Chest.all(:gas_spec, :surface_spec)).
          to match_array([methane_base, bridge_base]) }
      end

      describe '#purge!' do
        describe 'only one' do
          before(:each) do
            Chest.store(methane_base)
            Chest.purge!(methane_base)
          end

          it { expect { Chest.gas_spec(:methane) }.
            to raise_error keyname_error }
        end

        describe 'just many' do
          before(:each) do
            Chest.store(dimers_row, at_end)
            Chest.purge!(dimers_row, at_end)
          end

          it { expect { Chest.where(:dimers_row, :at_end) }.
            to raise_error keyname_error }
        end
      end
    end

  end
end
