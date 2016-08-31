#ifndef BEHAVIOR_FACTORY_H
#define BEHAVIOR_FACTORY_H

#include "../tools/factory.h"
#include "behavior.h"

namespace vd
{

class BehaviorFactory : public Factory<Behavior, std::string>
{
public:
    BehaviorFactory();
};

}

#endif // BEHAVIOR_FACTORY_H
