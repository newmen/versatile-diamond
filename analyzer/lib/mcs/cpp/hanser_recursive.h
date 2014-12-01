#ifndef HANSER_RECURSIVE_H
#define HANSER_RECURSIVE_H

#include <assert.h>
#include <algorithm>
#include <list>
#include <vector>
#include "assoc_graph.h"
#include "union_diff_operations.h"

/*
 * The modified Hanser's recursive algorithm for find of subgraph in graph
 * V is type of vertex of assoc graph
 */
template <typename V>
class HanserRecursive
{
    typedef AssocGraph<V> AG;
    AG *_g;

public:
    typedef typename AG::Vertices Intersec;
    typedef std::list<Intersec> Intersections;

    HanserRecursive();
    ~HanserRecursive();

    // Stores the edge to assoc graph
    void addEdge(V v, V w, bool isExt = true);

    // Finds all possible intersections by assoc graph
    Intersections intersections() const;

private:
    HanserRecursive(const HanserRecursive &) = delete;
    HanserRecursive(HanserRecursive &&) = delete;
    HanserRecursive &operator = (const HanserRecursive &) = delete;
    HanserRecursive &operator = (HanserRecursive &&) = delete;

    class Collector
    {
        Intersections _intersections;
        unsigned _maxSize = 0;

    public:
        void adsorbIntersec(const Intersec &intersec)
        {
            unsigned size = intersec.size();
            if (size < _maxSize) return;
            if (size > _maxSize)
            {
                _maxSize = size;
                _intersections.clear();
            }
            _intersections.push_back(intersec);
        }

        const Intersections &intersections() const
        {
            return _intersections;
        }
    };

    void findClique(Collector *pCollector, const Intersec &intersec, const Intersec &qPlus, const Intersec &qMinus) const;
};

///////////////////////////////////////////////////////////////////////////////

template <typename V>
HanserRecursive<V>::HanserRecursive()
{
    _g = new AG;
}

template <typename V>
HanserRecursive<V>::~HanserRecursive()
{
    delete _g;
}

template <typename V>
void HanserRecursive<V>::addEdge(V v, V w, bool isExt)
{
    _g->addEdge(v, w, isExt);
}

template <typename V>
typename HanserRecursive<V>::Intersections HanserRecursive<V>::intersections() const
{
    Collector collector;
    findClique(&collector, Intersec(), _g->allVertices(), Intersec());

    return collector.intersections();
}

template <typename V>
void HanserRecursive<V>::findClique(Collector *pCollector,
                              const HanserRecursive<V>::Intersec &intersec,
                              const HanserRecursive<V>::Intersec &qPlus,
                              const HanserRecursive<V>::Intersec &qMinus) const
{
    pCollector->adsorbIntersec(intersec);
    if (qPlus.empty()) return;

    // simplified clique searching algorithm
    Intersec cutPlus(diffOp(qPlus, intersec));
    Intersec extMinus(qMinus);
    for (const V &v : cutPlus)
    {
        Intersec nextMinus = unionOp(extMinus, _g->fbnNeighbours(v));
        Intersec nextPlus;
        if (intersec.empty())
        {
            nextPlus = diffOp(_g->extNeighbours(v), nextMinus);
        }
        else
        {
            nextPlus = diffOp(unionOp(qPlus, _g->extNeighbours(v)), nextMinus);
        }

        if (std::find(extMinus.cbegin(), extMinus.cend(), v) == extMinus.cend())
        {
            extMinus.push_back(v);
        }

        Intersec nextIntersec(intersec);
        if (std::find(nextIntersec.cbegin(), nextIntersec.cend(), v) == nextIntersec.cend())
        {
            nextIntersec.push_back(v);
        }

        findClique(pCollector, nextIntersec, nextPlus, nextMinus);
    }
}

#endif // HANSER_RECURSIVE_H
