module VersatileDiamond
  module Mcs

    # Hanser's recursive algorithm search maximal common substructure (MCS).
    # General description of the algorithm on russian language could be found
    # there: http://www.scitouch.net/downloads/mcs_article.pdf
    class HanserRecursiveAlgorithm
      include Mcs::IntersecProjection

      class << self
        # Finds first intersection in passed association graph
        # @param [AssocGraph] assoc_graph the association graph in which search
        #   will be carried out
        # @return [Set] the first intersection
        def first_intersec(assoc_graph)
          new(assoc_graph).intersec.first
        end
      end

      # Initialize an instance by association graph
      # @param [AssocGraph] assoc_graph see at #self.intersec same arg
      def initialize(assoc_graph)
        @assoc_graph = assoc_graph

        # TODO: may be need to add forbidden self-closed edges to assoc graph
        if @assoc_graph.vertices.size > 1
          @ids_to_vertices = {}
          @hanser_pointer = FfiHanser.createHanserRecursive

          adsorb_edges(assoc_graph, true)
          adsorb_edges(assoc_graph, false)
        end
      end

      # Finds all intersection of associated structures. Once all possible
      # intersections are found, are selected only those projections of that
      # correspond to associated structures.
      #
      # @return [Array] the array of all possible intersec
      def intersec
        if @assoc_graph.vertices.size > 1
          intersec_result_pointer = FfiHanser.collectIntersections(@hanser_pointer)
          result = []

          i = 0
          isec_size = intersec_result_pointer[:intersectSize]
          data = intersec_result_pointer[:data]
          intersec_result_pointer[:intersectsNum].times do
            isec = []
            isec_size.times do
              id = data[i].read_uint64
              isec << @ids_to_vertices[id]
              i += FFI::TYPE_UINT64.size
            end
            result << isec
          end

          FfiHanser.destroyAllData(@hanser_pointer, intersec_result_pointer)
          result
        else
          [@assoc_graph.vertices]
        end
      end

    private

      # Stores vertex object id and returns it
      # @param [Object] v for which the object id will be stored
      # @return [Integer] the object id of passed vertex
      def vertex_id(v)
        id = v.object_id
        return id if @ids_to_vertices[id]

        @ids_to_vertices[id] = v
        id
      end

      # Adsorbs edges from passed assoc graph to cpp solver
      # @param [AssocGraph] assoc_graph from which the edges of different types adsorbs
      # @param [Boolean] is_ext setups the type of adsorbing edges and if true then
      #   adsorbs the existent edges or forbidden edges overwise
      def adsorb_edges(assoc_graph, is_ext)
        vname = is_ext ? :ext : :fbn
        assoc_graph.public_send(:"each_#{vname}_edge") do |v, w|
          FfiHanser.addEdgeTo(@hanser_pointer, vertex_id(v), vertex_id(w), is_ext)
        end
      end
    end

  end
end
