#include "sample.h"
#include <iostream>

void Sample::adsorb(const StudyUnit *unit)
{
    std::cout << "Event type: " << unit->eventType() << "\n"
              << "Begin cell state: " << unit->beginState() << "\n"
              << "End cell state: " << unit->endState() << "\n"
              << "Around cells states: ";

    for (ushort state : unit->aroundStates())
    {
         std::cout << state << " ";
    }

    std::cout << "\n" << std::endl;
}
