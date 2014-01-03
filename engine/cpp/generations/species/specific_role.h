#ifndef SPECIFIC_ROLE_H
#define SPECIFIC_ROLE_H

#include "../handbook.h"

template <class B>
class SpecificRole : public B
{
protected:
    template <class... Args>
    SpecificRole(Args... args) : B(args...) {}

    void keepFirstTime() override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B>
void SpecificRole<B>::keepFirstTime()
{
    Handbook::specificKeeper().store(this);
}

#endif // SPECIFIC_ROLE_H
