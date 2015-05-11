#include "dump_saver_builder.h"
#include "decorator/queue_item.h"

namespace vd {

void DumpSaverBuilder::save(const SavingAmorph *amorph, const SavingCrystal *crystal, const char *, double currentTime)
{
    _dmpSaver->save(_x, _y,currentTime, amorph, crystal, _detector);
}

}
