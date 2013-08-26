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
      it { subject.visit(Visitor.new).should be_true }
    end

  end
end
