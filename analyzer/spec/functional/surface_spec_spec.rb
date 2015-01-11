require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe SurfaceSpec, type: :interpreter do
      let(:concept) { Concepts::SurfaceSpec.new(:spec_name) }
      let(:spec) { Interpreter::SurfaceSpec.new(concept) }

      before do
        interpret_basis
        spec.interpret('atoms c1: C%d, c2: C%d, c3: C%d')
      end

      describe 'default behavior for position instances' do
        it { expect {
            spec.interpret("position :c1, :c2, face: 100, dir: :front")
          }.not_to raise_error }

        it { expect {
            spec.interpret("no-position :c1, :c2, face: 100, dir: :front")
          }.to raise_error(*syntax_error('non_position.impossible')) }

        describe 'when position already present' do
          before do
            spec.interpret("position :c3, :c2, face: 100, dir: :front")
          end

          it { expect {
              spec.interpret("no-position :c1, :c2, face: 100, dir: :front")
            }.not_to raise_error }
        end

        describe 'when only bond presented' do
          before do
            spec.interpret("bond :c3, :c2, face: 100, dir: :front")
          end

          it { expect {
              spec.interpret("no-position :c1, :c2, face: 100, dir: :front")
            }.to raise_error(*syntax_error('non_position.impossible')) }
        end
      end

      %w(position no-position).each do |relation|
        describe "##{relation}" do
          describe 'both atoms has lattice' do
            let(:incomplete) { syntax_error('position.incomplete') }

            it { expect { spec.interpret("#{relation} :c1, :c2, face: 100") }.
              to raise_error(*incomplete) }

            it { expect { spec.interpret("#{relation} :c1, :c2, dir: :front") }.
              to raise_error(*incomplete) }
          end

          describe 'only one atom has lattice' do
            before(:each) do
              spec.interpret('atoms c1: C%d, c2: C')
            end

            let(:undefined_relation) do
              (relation =~ /^no-/) ? non_position_100_front : position_100_front
            end

            it { expect {
                spec.interpret("#{relation} :c1, :c2, face: 100, dir: :front")
              }.to raise_error(*syntax_error(
                'surface_spec.undefined_relation', relation: undefined_relation))
            }
          end

          describe 'duplication' do
            let(:spec) { Interpreter::SurfaceSpec.new(bridge_base) }

            it { expect {
                spec.interpret("#{relation} :cl, :cr, face: 100, dir: :front")
              }.to raise_error(*syntax_warning(
                'position.duplicate', face: 100, dir: :front)) }
          end
        end
      end
    end

  end
end
