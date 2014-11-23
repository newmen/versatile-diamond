#ifdef NEYRON
#ifndef STUDY_UNIT_H
#define STUDY_UNIT_H

#include <vector>
#include <atoms/atom.h>
#include <tools/common.h>
using namespace vd;

#include "tails_translator.h"

// Содержит информацию о произошедшем событии. Запоминает следующие характеристики события:
// состояние атома до события и состояние после события, состояния всех окружающих атомов до события,
// а также запоминается тип события.
class StudyUnit
{
    static TailsTranslator __tt;

    ushort _reactionType;
    ushort _prevState = 0, _nextState = 0;
    std::vector<ushort> _aroundStates;
    ushort _aroundStateIndex = 0;

public:
    // Статическая информация для инициализации обучаемого объекта
    static const ushort inputValuesNum;
    static const ushort outputValuesNum;
    static const ushort eventsNum;
    static const ushort atomStatesNum;

    StudyUnit(ushort reactionType, Atom *atom);
    void storeEndState(Atom *atom);

    // Методы для получения информации о событии
    ushort eventType() const { return _reactionType; }
    ushort beginState() const { return _prevState; }
    ushort endState() const { return _nextState; }
    const std::vector<ushort> &aroundStates() const;

private:
    StudyUnit(const StudyUnit &) = delete;
    StudyUnit(StudyUnit &&) = delete;
    StudyUnit &operator = (const StudyUnit &) = delete;
    StudyUnit &operator = (StudyUnit &&) = delete;

    void storeState(ushort state);
};

#endif // STUDY_UNIT_H
#endif // NEYRON
