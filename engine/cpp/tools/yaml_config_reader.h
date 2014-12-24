#ifndef YAML_CONFIG_READER_H
#define YAML_CONFIG_READER_H

#include <yaml-cpp/yaml.h>

namespace vd
{

class YAMLConfigReader
{
    YAML::Node _root;

public:
    explicit YAMLConfigReader(const char *filename);

    template <typename T, class... Args>
    T read(const char *key, Args... args) const;

private:
    template <typename T>
    T recursiveRead(const YAML::Node &node, const char *key) const;

    template <typename T, class... Args>
    T recursiveRead(const YAML::Node &node, const char *key, Args... args) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <typename T, class... Args>
T YAMLConfigReader::read(const char *key, Args... args) const
{
    return recursiveRead<T>(_root, key, args...);
}

template <typename T>
T YAMLConfigReader::recursiveRead(const YAML::Node &node, const char *key) const
{
    return node[key].as<T>();
}

template <typename T, class... Args>
T YAMLConfigReader::recursiveRead(const YAML::Node &node, const char *key, Args... args) const
{
    return recursiveRead<T>(node[key], args...);
}

}

#endif // YAML_CONFIG_READER_H
