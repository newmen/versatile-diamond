require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Reaction, type: :interpreter do
      describe '#equation' do
        let(:is_active_bond) { -> s { s.class == Concepts::ActiveBond } }
        let(:is_atomic_spec) { -> s { s.class == Concepts::AtomicSpec } }
        let(:is_specific_spec) { -> s { s.class == Concepts::SpecificSpec } }

        it 'error when spec name is undefined' do
          expect { reaction.interpret('equation * + hydrogen(h: *) = H') }.
            to raise_error(*keyname_error(:undefined, :spec, :hydrogen))
        end

        describe 'ubiquitous equation' do
          let(:concept) do
            Tools::Chest.ubiquitous_reaction('forward reaction name')
          end

          before(:each) do
            elements.interpret('atom H, valence: 1')
            gas.interpret('spec :hydrogen')
            gas.interpret('  atoms h: H')
            reaction.interpret('equation * + hydrogen(h: *) = H')
          end

          it { expect(concept.class).to eq(Concepts::UbiquitousReaction) }

          describe 'respects' do
            it { expect(concept.source.one?(&is_active_bond)).to be_truthy }
            it { expect(concept.source.one?(&is_specific_spec)).to be_truthy }
            it { expect(concept.products.one?(&is_atomic_spec)).to be_truthy }
          end

          describe 'not respects' do
            it { expect(concept.products.one?(&is_active_bond)).to be_falsey }
            it { expect(concept.products.one?(&is_specific_spec)).to be_falsey }
            it { expect(concept.source.one?(&is_atomic_spec)).to be_falsey }
          end

          it "don't nest equation interpreter instance" do
            expect { reaction.interpret('  refinement "some"') }.
              to raise_error(*syntax_error('common.wrong_hierarchy'))
          end
        end

        describe 'not ubiquitous equation' do
          let(:concept) { Tools::Chest.reaction('forward reaction name') }

          before(:each) { interpret_basis }

          it 'not complience reactants' do
            expect { reaction.interpret(
                'equation bridge(cr: *) + bridge = bridge + bridge(ct: *)') }.
              to raise_error(*syntax_error(
                'reaction.cannot_map', name: 'bridge'))
          end

          describe 'reaction with dangling H' do
            before do
              elements.interpret('atom H, valence: 1')
              gas.interpret('spec :hydrogen')
              gas.interpret('  atoms h: H')
            end

            it { expect { reaction.interpret(
                'equation methyl_on_bridge(cm: H) + hydrogen(h: *) = methyl_on_bridge(cm: *) + hydrogen') }.
              not_to raise_error }
          end

          describe 'simple reaction' do
            before(:each) do
              reaction.interpret('equation bridge(ct: *) + methane(c: *) = methyl_on_bridge')
            end

            it { expect(concept.class).to eq(Concepts::Reaction) }

            describe 'all is specific spec' do
              it { expect(concept.source.all?(&is_specific_spec)).to be_truthy }
              it { expect(concept.products.all?(&is_specific_spec)).to be_truthy }
            end

            it 'nest equation interpreter instance' do
              expect { reaction.interpret('  refinement "some"') }.
                not_to raise_error
            end

            describe 'refinements' do
              it { expect { reaction.interpret('  incoherent bridge(:ct)') }.
                not_to raise_error }
              it { expect { reaction.interpret('  unfixed methyl_on_bridge(:cm)') }.
                to raise_error(Concepts::SpecificAtom::AlreadyStated) }
            end
          end

          describe 'setup corresponding relevant' do
            describe 'incoherent states' do
              describe 'by keyname modifier' do
                before(:each) do
                  surface.interpret('spec :bridge_with_dimer')
                  surface.interpret('  aliases dm: dimer')
                  surface.interpret('  atoms ct: C%d, cl: bridge(:ct), cr: dm(:cr), cf: dm(:cl)')
                  surface.interpret('  bond :ct, :cl, face: 110, dir: :cross')
                  surface.interpret('  bond :ct, :cr, face: 110, dir: :cross')

                  reaction.interpret('aliases one: bridge, two: bridge')
                  reaction.interpret('equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer')
                end

                it { expect(concept.products.first.atom(:cf).incoherent?).
                  to be_truthy }
              end

              describe 'by operator' do
                before(:each) do
                  reaction.interpret('aliases one: bridge, two: bridge')
                  reaction.interpret('equation one(ct: *) + two(ct: *) = dimer')
                  reaction.interpret('  incoherent one(:ct), two(:ct)')
                end

                let(:dimer) { concept.products.first }
                it { expect(dimer.atom(:cr).incoherent?).to be_truthy }
                it { expect(dimer.atom(:cl).incoherent?).to be_truthy }
              end
            end

            describe 'unfixed states' do
              shared_examples_for :check_both_unfixed do
                it { expect(concept.source.first.atom(:cm).unfixed?).
                  to be_truthy }
                it { expect(concept.products.first.atom(:cm).unfixed?).
                  to be_truthy }
              end

              shared_examples_for :check_unfixed_only_one do
                it { expect(concept.source.first.atom(:cm).unfixed?).
                  to be_truthy }
                it { expect(concept.products.first.atom(:cm).unfixed?).
                  to be_falsey }
              end

              before(:each) do
                surface.interpret('spec :methyl_on_dimer')
                surface.interpret('  aliases mb: methyl_on_bridge')
                surface.interpret('  atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)')
                surface.interpret('  bond :cl, :cr, face: 100, dir: :front')
              end

              describe 'by keyname modifier' do
                describe 'for exchange reaction type' do
                  before(:each) do
                    reaction.interpret('equation methyl_on_dimer + dimer(cr: *) = methyl_on_dimer(cm: *, cm: u) + dimer')
                  end

                  it_behaves_like :check_both_unfixed
                end

                describe 'when high bridge forms' do
                  before(:each) do
                    reaction.interpret('equation methyl_on_dimer(cm: *, cm: u) = high_bridge + bridge(ct: *)')
                  end

                  it_behaves_like :check_unfixed_only_one
                end
              end

              describe 'by operator' do
                describe 'for exchange reaction type' do
                  before(:each) do
                    reaction.interpret('equation methyl_on_dimer + dimer(cr: *) = methyl_on_dimer(cm: *) + dimer')
                    reaction.interpret('  unfixed methyl_on_dimer(:cm)')
                  end

                  it_behaves_like :check_both_unfixed
                end

                describe 'when high bridge forms' do
                  before(:each) do
                    reaction.interpret('equation methyl_on_dimer(cm: *) = high_bridge + bridge(ct: *)')
                    reaction.interpret('  unfixed methyl_on_dimer(:cm)')
                  end

                  it_behaves_like :check_unfixed_only_one
                end
              end
            end
          end

          describe 'incomplete bridge with dimer' do
            before(:each) do
              surface.interpret('spec :bridge_with_dimer')
              surface.interpret('  atoms cr: bridge(:cr), cf: bridge(:ct)')
              surface.interpret('  bond :cr, :cf, face: 100, dir: :front')

              reaction.interpret('aliases one: bridge, two: bridge')
              reaction.interpret(
                'equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer')
            end

            it { expect(concept.products.first.atom(:cf).incoherent?).
              to be_truthy }
          end

          describe 'not initialy balanced reaction' do
            describe 'extending product' do
              before(:each) do
                reaction.interpret('aliases source: bridge, product: bridge')
                reaction.interpret(
                  'equation high_bridge + source(ct: *) = product(cr: *)')
              end

              it { expect(concept.source.first.external_bonds).to eq(4) }
              it { expect(concept.source.last.external_bonds).to eq(3) }
              it { expect(concept.products.first.external_bonds).to eq(7) }
            end

            describe 'extending first source and single product' do
              before(:each) do
                reaction.interpret('aliases source: dimer, product: dimer')
                reaction.interpret(
                  'equation methyl_on_bridge(cm: *) + source(cr: *) = product')
              end

              it { expect(concept.source.first.external_bonds).to eq(9) }
              it { expect(concept.source.last.external_bonds).to eq(5) }
              it { expect(concept.products.first.external_bonds).to eq(14) }
            end
          end

          describe 'one to three' do
            before(:each) do
              reaction.interpret('aliases one: bridge, two: bridge')
            end

            it { expect { reaction.interpret(
                'equation dimer(cr: *) = high_bridge(cm: *) + one(ct: *) + two(ct: *)'
              ) }.not_to raise_error }
          end

          describe 'reaction with wrong balance' do
            it { expect { reaction.interpret(
                'equation bridge(cr: *, cl: *) + methane(c: *) = methyl_on_bridge'
              ) }.to raise_error(*syntax_error('reaction.wrong_balance')) }
          end
        end

        describe 'lateral reaction' do
          before(:each) do
            interpret_basis

            events.interpret('environment :dimers_row')
            events.interpret('  targets :one, :two')
            events.interpret('  aliases left: dimer, right: dimer')
            events.interpret("  where :end_row, 'at end'")
            events.interpret('    position one, left(:cl), face: 100, dir: :cross')
            events.interpret('    position two, left(:cr), face: 100, dir: :cross')
            events.interpret("  where :mid_row, 'in middle'")
            events.interpret('    use :end_row')
            events.interpret('    position one, right(:cl), face: 100, dir: :cross')
            events.interpret('    position two, right(:cr), face: 100, dir: :cross')

            reaction.interpret('aliases one: bridge, two: bridge')
            reaction.interpret('equation one(ct: *) + two(ct: *) = dimer')
            reaction.interpret('  lateral :dimers_row, one: one(:ct), two: two(:ct)')

            reaction.interpret("  refinement 'not in dimers row'")
            reaction.interpret('  there :end_row')
            reaction.interpret('  there :mid_row')
          end

          describe 'not in dimers row' do
            subject do
              Tools::Chest.reaction('forward reaction name not in dimers row')
            end

            let(:c_bridge1) { subject.source.first }
            let(:c_bridge2) { subject.source.last }

            it { expect(subject.positions).to match_array([
                [
                  [c_bridge1, c_bridge1.atom(:ct)],
                  [c_bridge2, c_bridge2.atom(:ct)],
                  position_100_front
                ],
                [
                  [c_bridge2, c_bridge2.atom(:ct)],
                  [c_bridge1, c_bridge1.atom(:ct)],
                  position_100_front
                ],
              ]) }
          end

          describe 'lateral members' do
            let(:there) { subject.theres.first }
            let(:c_bridge1) { subject.source.first }
            let(:c_bridge2) { subject.source.last }

            describe 'at end' do
              subject do
                Tools::Chest.lateral_reaction('forward reaction name at end')
              end

              let(:w_dimer) { there.env_specs.first }

              it { expect(subject.theres.size).to eq(1) }
              it { expect(there.links).to match_graph({
                  [c_bridge1, c_bridge1.atom(:ct)] => [
                    [[w_dimer, w_dimer.atom(:cl)], position_100_cross]
                  ],
                  [c_bridge2, c_bridge2.atom(:ct)] => [
                    [[w_dimer, w_dimer.atom(:cr)], position_100_cross]
                  ],
                }) }
            end

            describe 'in middle' do
              subject do
                Tools::Chest.lateral_reaction('forward reaction name in middle')
              end

              let(:w_dimer1) { there.env_specs.first }
              let(:w_dimer2) { there.env_specs.last }

              it { expect(subject.theres.size).to eq(1) }
              it { expect(there.links).to match_graph({
                  [c_bridge1, c_bridge1.atom(:ct)] => [
                    [[w_dimer1, w_dimer1.atom(:cl)], position_100_cross],
                    [[w_dimer2, w_dimer2.atom(:cl)], position_100_cross],
                  ],
                  [c_bridge2, c_bridge2.atom(:ct)] => [
                    [[w_dimer1, w_dimer1.atom(:cr)], position_100_cross],
                    [[w_dimer2, w_dimer2.atom(:cr)], position_100_cross],
                  ],
                }) }
            end
          end
        end
      end

      it_behaves_like :reaction_properties do
        let(:target) { reaction }
        let(:reverse) { Tools::Chest.reaction('reverse reaction name') }
      end

      describe 'extended specs exchanges in names and specs' do
        before do
          interpret_basis
          reaction.interpret('aliases source: dimer, product: dimer')
          reaction.interpret(
            'equation methyl_on_bridge(cm: *, cm: u, cb: i) + source(cr: *) = product')
        end

        it { expect { reaction.interpret(
            '  position methyl_on_bridge(:cl), source(:cl), face: 100, dir: :cross'
          ) }.not_to raise_error }
      end
    end

  end
end
