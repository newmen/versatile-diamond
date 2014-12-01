#ifndef GRAPH_H
#define GRAPH_H

#include <unordered_map>
#include <unordered_set>

/*
 * The typical unordered sparce graph, where
 * V is type of vertex
 */
template <typename V>
class Graph
{
public:
    typedef std::unordered_set<V> Vertices;

private:
    typedef std::unordered_map<V, Vertices> HashTable;
    HashTable _g;

public:
    Graph() = default;

    void addEdge(V v, V w);

    Vertices vertices() const;
    Vertices neighbours(V v) const;

private:
    Graph(const Graph &) = delete;
    Graph(Graph &&) = delete;
    Graph &operator = (const Graph &) = delete;
    Graph &operator = (Graph &&) = delete;
};

///////////////////////////////////////////////////////////////////////////////

template <class V>
void Graph<V>::addEdge(V v, V w)
{
    _g[v].insert(w);
    _g[w].insert(v);
}

template <class V>
typename Graph<V>::Vertices Graph<V>::vertices() const
{
    Vertices result;
    for (const typename HashTable::value_type &kvl : _g)
    {
        result.insert(kvl.first);
    }
    return result;
}

template <class V>
typename Graph<V>::Vertices Graph<V>::neighbours(V v) const
{
    if (_g.find(v) == _g.cend())
    {
        return Vertices();
    }
    else
    {
        return _g.find(v)->second;
    }
}

#endif // GRAPH_H
