#ifdef NEYRON
#ifndef LOCALIZATOR_H
#define LOCALIZATOR_H

#include "study_unit.h"

// Базовый класс для любого рода анализатора событий в моделируемой системе.
class Localizator
{
public:
    Localizator();
    virtual ~Localizator() {}

    virtual void adsorb(const StudyUnit *unit) = 0;
};

#endif // LOCALIZATOR_H
#endif // NEYRON
