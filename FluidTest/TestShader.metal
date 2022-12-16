//
//  TestShader.metal
//  FluidTest
//
//  Created by Liam on 16/12/2022.
//

#include <metal_stdlib>
using namespace metal;

// Simple vertex shader
vertex float4 simple_vertex_function(constant float4 *vertices [[ buffer(0) ]],
                                     uint vertex_id [[ vertex_id ]])
{
    // Return the input vertex unmodified
    return vertices[vertex_id];
}

// Simple fragment shader
fragment float4 simple_fragment_function()
{
    // Return a fixed color
    return float4(1.0, 1.0, 0.0, 1.0);
}

