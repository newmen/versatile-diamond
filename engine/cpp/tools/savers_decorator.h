#ifndef SAVER_DECORATOR
#define SAVER_DECORATOR

#include "../phases/amorph.h"
#include "../phases/crystal.h"

namespace vd {

class SaversDecorator
{
public:
    virtual void saveData(double currentTime, std::string filename) = 0;
    virtual void copyData() = 0;
    virtual Amorph* amorph() = 0;
    virtual Crystal* crystal() = 0;
};

}

#endif // SAVER_DECORATOR

