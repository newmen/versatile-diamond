module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents handbook class statement
        class HandbookClass < Core::ObjectType

          NAME = 'Handbook'.freeze

          class << self
            # @param [Object] name
            # @return [HandbookClass]
            def []
              super(NAME)
            end
          end

          # @return [AtomVariable] var
          # @return [Core::FunctionCall]
          def insert_amorph_atom(var)
            amorph.member('insert', var)
          end

          # @return [AtomVariable] var
          # @return [Core::FunctionCall]
          def erase_amorph_atom(var)
            amorph.member('erase', var)
          end

          # @return [AtomVariable] var
          # @return [Core::FunctionCall]
          def mark_removing_atom(var)
            scavenger.member('markAtom', var)
          end

        private

          # @return [OpNs]
          def amorph
            call('amorph')
          end

          # @return [OpNs]
          def scavenger
            call('scavenger')
          end
        end

      end
    end
  end
end
