#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../volume_saver.h"

namespace vd {

class DumpSaver : public VolumeSaver
{
    uint _x, _y;
public:
    explicit DumpSaver(const char *name, uint x, uint y): VolumeSaver(name), _x(x), _y(y) {}

    void save(double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector) override;

    uint x() const { return _x; }
    uint y() const { return _y; }

private:
    DumpSaver(const DumpSaver &) = delete;
    DumpSaver(DumpSaver &&) = delete;
    DumpSaver &operator = (const DumpSaver &) = delete;
    DumpSaver &operator = (DumpSaver &&) = delete;

    std::string filename() const override;
    const char *ext() const override;
};

}
#endif // DUMP_SAVER_H
