#ifdef NEYRON
#include "localizators_pack.h"

LocalizatorsPack::~LocalizatorsPack()
{
    for (Localizator *localizator : _localizators)
    {
        delete localizator;
    }
}

void LocalizatorsPack::add(Localizator *localizator)
{
    _localizators.push_back(localizator);
}
#endif // NEYRON
