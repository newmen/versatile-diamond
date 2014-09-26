#ifdef NEYRON
#ifndef LOCALIZATORS_PACK_H
#define LOCALIZATORS_PACK_H

#include <algorithm>
#include <vector>
#include "localizator.h"

class LocalizatorsPack
{
    std::vector<Localizator *> _localizators;

public:
    LocalizatorsPack() = default;
    ~LocalizatorsPack();

    void add(Localizator *localizator);
    template <class L> void each(const L &lambda);
};

template <class L>
void LocalizatorsPack::each(const L &lambda)
{
    std::for_each(_localizators.begin(), _localizators.end(), lambda);
}

#endif // LOCALIZATORS_PACK_H
#endif // NEYRON
