#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "one_file.h"
#include "mol_saver.h"

namespace vd
{

class SdfSaver : public OneFile<MolSaver>
{
public:
    explicit SdfSaver(const char *name) : OneFile(name) {}

protected:
    const char *ext() const override;
    const char *separator() const override;

private:
    SdfSaver(const SdfSaver &) = delete;
    SdfSaver(SdfSaver &&) = delete;
    SdfSaver &operator = (const SdfSaver &) = delete;
    SdfSaver &operator = (SdfSaver &&) = delete;
};

}

#endif // SDF_SAVER_H
