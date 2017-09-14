#ifndef YAML_CONFIG_READER_H
#define YAML_CONFIG_READER_H

#include <yaml-cpp/yaml.h>
#include <vector>

namespace vd
{

class YAMLConfigReader
{
    YAML::Node _root;

public:
    explicit YAMLConfigReader(const std::string &filePath);

    template <typename T, class... Args>
    T read(const char *key, Args... args) const;

    template <class... Args>
    bool isDefined(const char *key, Args... args) const;

private:
    template <typename T>
    T recursiveRead(const YAML::Node &node, const char *key) const;

    template <typename T, class... Args>
    T recursiveRead(const YAML::Node &node, const char *key, Args... args) const;

    bool recursiveIsDefined(const YAML::Node &node, const char *key) const;

    template <class... Args>
    bool recursiveIsDefined(const YAML::Node &node, const char *key, Args... args) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <typename T, class... Args>
T YAMLConfigReader::read(const char *key, Args... args) const
{
    return recursiveRead<T>(_root, key, args...);
}

template <class... Args>
bool YAMLConfigReader::isDefined(const char *key, Args... args) const
{
    return recursiveIsDefined(_root, key, args...);
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

template <class... Args>
bool YAMLConfigReader::recursiveIsDefined(const YAML::Node &node, const char *key, Args... args) const
{
    return recursiveIsDefined(node[key], args...);
}

}

#endif // YAML_CONFIG_READER_H
