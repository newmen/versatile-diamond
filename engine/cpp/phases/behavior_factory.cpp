#include "behavior_factory.h"
#include "behavior_plane.h"
#include "behavior_tor.h"

namespace vd
{

BehaviorFactory::BehaviorFactory()
{
    registerNewType<BehaviorTor>("tor");
    registerNewType<BehaviorPlane>("plane");
}

}
