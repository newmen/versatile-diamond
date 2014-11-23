#ifdef NEYRON
#include "study_unit.h"
#include "../handbook.h"

TailsTranslator StudyUnit::__tt;

// There 2 is number of additional states, like: eventType and beginState
const ushort StudyUnit::inputValuesNum = Handbook::__atomsClusterSize + 2;

// There 1 is number of state, like: endState
const ushort StudyUnit::outputValuesNum = 1;

const ushort StudyUnit::eventsNum = ALL_SPEC_REACTIONS_NUM + UBIQUITOUS_REACTIONS_NUM;
const ushort StudyUnit::atomStatesNum = Handbook::__tailStatesNum;

/* ------------------------------------------------------------------------ */

StudyUnit::StudyUnit(ushort reactionType, Atom *atom) :
    _reactionType(reactionType), _aroundStates(Handbook::__atomsClusterSize, 0)
{
    if (atom->prevType() != NO_VALUE)
    {
        _prevState = __tt.translate(atom->type());
        atom->eachAroundAtom([this](Atom *a) {
            storeState(a ? a->type() : 0);
        });
    }
}

void StudyUnit::storeEndState(Atom *atom)
{
    if (_prevState == 0)
    {
        atom->eachAroundAtom([this](Atom *a) {
            ushort state = a ? a->prevType() : 0;
            if (state == NO_VALUE)
            {
                state = a->type();
            }

            storeState(state);
        });
    }
    _nextState = atom->type();
}

void StudyUnit::storeState(ushort state)
{
    assert(_aroundStateIndex < Handbook::__atomsClusterSize);
    _aroundStates[_aroundStateIndex++] = __tt.translate(state);
}
#endif // NEYRON
