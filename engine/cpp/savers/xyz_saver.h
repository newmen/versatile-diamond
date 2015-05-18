#ifndef XYZ_SAVER_H
#define XYZ_SAVER_H

#include "many_files.h"
#include "xyz_accumulator.h"
#include "bundle_saver.h"
#include "xyz_format.h"

namespace vd
{

class XYZSaver : public ManyFiles<BundleSaver<XYZAccumulator, XYZFormat>>
{
public:
    explicit XYZSaver(const char *name): ManyFiles(name) {}

protected:
    const char *ext() const override;

private:
    XYZSaver(const XYZSaver &) = delete;
    XYZSaver(XYZSaver &&) = delete;
    XYZSaver &operator = (const XYZSaver &) = delete;
    XYZSaver &operator = (XYZSaver &&) = delete;
};

}

#endif // XYZ_SAVER_H
