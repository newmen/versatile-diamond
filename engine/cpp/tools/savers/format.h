#ifndef FORMAT_H
#define FORMAT_H

#include "volume_saver.h"

namespace vd
{

template <class AccType>
class Format
{
    const VolumeSaver &_saver;
    const AccType &_acc;

protected:
    Format(const VolumeSaver &saver, const AccType &acc) : _saver(saver), _acc(acc) {}

    const VolumeSaver &saver() const { return _saver; }
    const AccType &acc() const { return _acc; }

    std::string timestamp() const;
};

/////////////////////////////////////////////////////////////////////////////////////////

template <class A>
std::string Format<A>::timestamp() const
{
    time_t rawtime;
    struct tm *timeinfo;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%d-%m-%Y %H:%M:%S", timeinfo);
    return buffer;
}

}

#endif // FORMAT_H
