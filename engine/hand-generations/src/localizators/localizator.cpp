#include "localizator.h"
#include "../handbook.h"

void Localizator::registrate()
{
    Handbook::addLocalizator(this);
}
