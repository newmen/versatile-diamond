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

private:
    BehaviorFactory(const BehaviorFactory &) = delete;
    BehaviorFactory(BehaviorFactory &&) = delete;
    BehaviorFactory &operator = (const BehaviorFactory &) = delete;
    BehaviorFactory &operator = (BehaviorFactory &&) = delete;
};

}

#endif // BEHAVIOR_FACTORY_H
