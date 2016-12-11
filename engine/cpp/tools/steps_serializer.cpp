#ifdef SERIALIZE
#include "steps_serializer.h"
#include <fstream>

namespace vd
{

void StepsSerializer::appendSpec(const std::string &name, uint n)
{
    auto it = _specsStep.find(name);
    if (it == _specsStep.end())
    {
        _specsStep[name] = n;
    }
    else if (it->second + n == 0)
    {
        _specsStep.erase(it);
    }
    else
    {
        it->second += n;
    }
}

void StepsSerializer::step(const Dict &reactions)
{
    _reactions.push_back(reactions);
    _species.push_back(_specsStep);
}

void StepsSerializer::save() const
{
    nlohmann::json data = {
        { "reactions", toJson(_reactions) },
        { "species", toJson(_species) },
    };

    std::ofstream os("data.json");
    os << data;
    os.close();
}

nlohmann::json StepsSerializer::toJson(const Seq &seq) const
{
    nlohmann::json result = nlohmann::json::array();
    for (const Dict &dict : seq)
    {
        result.push_back(dict);
    }
    return result;
}

}

#endif // SERIALIZE
