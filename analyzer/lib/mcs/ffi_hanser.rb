require 'ffi'

module VersatileDiamond
  module Mcs

    module FfiHanser
      extend FFI::Library
      ffi_lib 'c'
      ffi_lib "#{__dir__}/lib/libhanser.so"

      class IntersecResult < FFI::Struct
        layout :intersectsNum, :uint,
               :intersectSize, :uint,
               :data, :pointer
      end

      attach_function :createHanserRecursive, [], :pointer

      attach_function :addEdgeTo, [:pointer, :uint, :uint, :bool], :void
      attach_function :collectIntersections, [:pointer], IntersecResult.ptr

      attach_function :destroyAllData, [:pointer, IntersecResult.ptr], :void
    end

  end
end
