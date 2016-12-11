#ifdef SERIALIZE
#ifndef STEPS_SERIALIZER_H
#define STEPS_SERIALIZER_H

#include <string>
#include <list>
#include <map>
#include <json.hpp>
#include "short_types.h"

namespace vd
{

class StepsSerializer
{
public:
    typedef std::map<std::string, uint> Dict;
private:
    typedef std::list<Dict> Seq;

    Seq _reactions;
    Seq _species;
    Dict _specsStep;

public:
    StepsSerializer() = default;

    void appendSpec(const std::string &name, uint n);
    void step(const Dict &reactions);
    void save() const;

private:
    StepsSerializer(const StepsSerializer &) = delete;
    StepsSerializer(StepsSerializer &&) = delete;
    StepsSerializer &operator = (const StepsSerializer &) = delete;
    StepsSerializer &operator = (StepsSerializer &&) = delete;

    nlohmann::json toJson(const Seq &seq) const;
};

}

#endif // STEPS_SERIALIZER_H
#endif // SERIALIZE
