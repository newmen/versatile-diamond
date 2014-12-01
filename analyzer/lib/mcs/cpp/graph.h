#ifndef GRAPH_H
#define GRAPH_H

#include <algorithm>
#include <list>
#include <unordered_map>

/*
 * The typical unordered sparce graph, where
 * V is type of vertex
 */
template <typename V>
class Graph
{
public:
    // There uses the list instead the set because we're depends from the order and it
    // is important for ruby tests
    typedef std::list<V> Vertices;

private:
    typedef std::unordered_map<V, Vertices> HashTable;
    HashTable _g;

    // Searated container for vertices becaulse we're depends from the original order
    // of vertices adding
    Vertices _vertices;

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

    void checkAndAdd(V v, V w);
};

///////////////////////////////////////////////////////////////////////////////

template <class V>
void Graph<V>::addEdge(V v, V w)
{
    checkAndAdd(v, w);
    checkAndAdd(w, v);
}

template <class V>
typename Graph<V>::Vertices Graph<V>::vertices() const
{
    return _vertices;
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

template <class V>
void Graph<V>::checkAndAdd(V v, V w)
{
    if (std::find(_vertices.cbegin(), _vertices.cend(), v) == _vertices.cend())
    {
        _vertices.push_back(v);
    }

    Vertices &nbrs = _g[v];
    if (std::find(nbrs.cbegin(), nbrs.cend(), w) == nbrs.cend())
    {
        nbrs.push_back(w);
    }
}

#endif // GRAPH_H
