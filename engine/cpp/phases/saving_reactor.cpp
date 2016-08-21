#include "saving_reactor.h"

namespace vd
{

SavingReactor::~SavingReactor()
{
    delete _amorph;
    delete _crystal;
}

}
