#include "savers_runner.h"

namespace vd {

SaversRunner::SaversRunner()
{
}

void SaversRunner::addSaver(VolumeSaver *sav, double time)
{

}

void SaversRunner::isNeedSave(double dt)
{
    //тут происходит опрос саверов на надобность в сохранении
    //а потом, собственно, сохранение
    //требуется создать поток для сохранения

}

}

