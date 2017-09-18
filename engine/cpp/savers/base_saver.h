#ifndef BASE_SAVER_H
#define BASE_SAVER_H

#include "../phases/saving_reactor.h"
#include "../tools/config.h"

namespace vd
{

class BaseSaver
{
    const Config *_config;

public:
    virtual ~BaseSaver() {}
    virtual void save(const SavingReactor *reactor) = 0;

    virtual bool needToInit() const { return true; } // by default

protected:
    BaseSaver(const Config *config) : _config(config) {}

    const Config *config() const { return _config; }

private:
    BaseSaver(const BaseSaver &) = delete;
    BaseSaver(BaseSaver &&) = delete;
    BaseSaver &operator = (const BaseSaver &) = delete;
    BaseSaver &operator = (BaseSaver &&) = delete;
};

}

#endif // BASE_SAVER_H
