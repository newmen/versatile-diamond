#ifndef ASSOC_GRAPH_H
#define ASSOC_GRAPH_H

#include <utility>
#include "unordered_set_operations.h"
#include "graph.h"

/*
 * The associating unordered sparce graph, where
 * V is type of vertex
 */
template <typename V>
class AssocGraph
{
public:
    typedef Graph<V> G;
    typedef typename G::Vertices Vertices;

private:
    G _ext, _fbn;

public:
    AssocGraph() = default;

    void addEdge(V v, V w, bool isExt = true);

    Vertices allVertices() const;
    Vertices extNeighbours(V v) const;
    Vertices fbnNeighbours(V v) const;

private:
    AssocGraph(const AssocGraph &) = delete;
    AssocGraph(AssocGraph &&) = delete;
    AssocGraph &operator = (const AssocGraph &) = delete;
    AssocGraph &operator = (AssocGraph &&) = delete;
};

///////////////////////////////////////////////////////////////////////////////

template <typename V>
void AssocGraph<V>::addEdge(V v, V w, bool isExt)
{
    if (isExt)
    {
        _ext.addEdge(v, w);
    }
    else
    {
        _fbn.addEdge(v, w);
    }
}

template <typename V>
typename AssocGraph<V>::Vertices AssocGraph<V>::allVertices() const
{
    return _fbn.vertices() + _ext.vertices();
}

template <typename V>
typename AssocGraph<V>::Vertices AssocGraph<V>::extNeighbours(V v) const
{
    return _ext.neighbours(v);
}

template <typename V>
typename AssocGraph<V>::Vertices AssocGraph<V>::fbnNeighbours(V v) const
{
    return _fbn.neighbours(v);
}

#endif // ASSOC_GRAPH_H
