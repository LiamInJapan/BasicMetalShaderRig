//
//  TestShader.metal
//  FluidTest
//
//  Created by Liam on 16/12/2022.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
};

struct Uniforms {
    float2 iResolution;
    texture2d<float, access::sample> iChannel0;
    texture2d<float, access::sample> iChannel1;
};

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

constexpr sampler s(address::clamp_to_edge, filter::nearest);

kernel void mainImage(
    texture2d<float, access::write> outTexture [[texture(0)]],
    uint2 gid [[thread_position_in_grid]],
    device VertexOut *outVertices [[buffer(1)]],
    texture2d<float> iChannel0 [[texture(2)]],
    texture2d<float> iChannel1 [[texture(3)]],
    sampler s [[sampler(0)]]
) {
    constexpr sampler samp(address::repeat, filter::linear);

    Uniforms uniforms;
    outVertices[0].texCoords = float2(gid);

    float2 coord = outVertices[0].texCoords / uniforms.iResolution.xy;
    float colorScale = 6.0 / uniforms.iResolution.y;

    float2 pixelStep = 3.0 / uniforms.iResolution.xy;

    float3 center = iChannel0.sample(s, coord).xyz;
    float3 top = iChannel0.sample(s, coord + float2(.0, pixelStep.y)).xyz;
    float3 right = iChannel0.sample(s, coord + float2(pixelStep.x, .0)).xyz;

    float sobelThreshold = .25;

    float tvVignette = 1.0 - 1.5 * dot(coord - float2(.5, .5), coord - float2(.5, .5));
    tvVignette *= .9 + .1 * sin(2.0 * outVertices[0].texCoords.y);

    float4 outColor = float4(
        tvVignette * iChannel1.sample(s, coord * (1.0 - colorScale)).r,
        tvVignette * iChannel1.sample(s, coord).g,
        tvVignette * iChannel1.sample(s, coord * (1.0 + colorScale)).b,
        1.0
    );
    if (dot(center - top, center - top) > sobelThreshold || dot(center - right, center - right) > sobelThreshold) {
        outColor = outColor * float4(.25, .25, .25, 1.0);
    }
    outTexture.write(outColor, gid);
}
