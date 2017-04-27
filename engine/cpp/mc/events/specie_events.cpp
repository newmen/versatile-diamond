#include "specie_events.h"

namespace vd
{

SpecieEvents::SpecieEvents(Slice *parent) : EventsWrapper<EventsContainer>(parent)
{
}

void SpecieEvents::add(SpecReaction *event)
{
    EventsContainer::add(event);
    updateParentRate(event, 1);
}

void SpecieEvents::remove(SpecReaction *event)
{
    EventsContainer::remove(event);
    updateParentRate(event, -1);
}

}
