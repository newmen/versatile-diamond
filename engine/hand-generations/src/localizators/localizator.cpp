#include "localizator.h"
#include "../handbook.h"

Localizator::Localizator()
{
    Handbook::addLocalizator(this);
}
