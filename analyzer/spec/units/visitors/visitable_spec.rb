require 'spec_helper'

module VersatileDiamond
  module Visitors

    describe Visitable do
      class SomeVisitableClass
        include Visitable
      end

      class Visitor
        def accept_some_visitable_class(some); true end
      end

      subject { SomeVisitableClass.new }
      it { should respond_to(:visit).with(1).argument }
      it { expect(subject.visit(Visitor.new)).to be_truthy }
    end

  end
end
