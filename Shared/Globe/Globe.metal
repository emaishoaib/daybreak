#include <metal_stdlib>
using namespace metal;

struct GlobeUniforms {
    float4 sun;
    float4 orientation;
    float4 size;
};

struct GlobeVertex {
    float4 position [[position]];
};

constant float atmosphereThickness = 0.07;
constant float3 cityLightColour = float3(1.0, 0.82, 0.55);
constant float3 moonlitLandColour = float3(0.2, 0.25, 0.4);
constant float3 duskColour = float3(1.0, 0.45, 0.2);
constant float3 atmosphereColour = float3(0.3, 0.55, 1.0);
constant float3 glintColour = float3(1.0, 0.95, 0.85);

vertex GlobeVertex globeVertex(uint id [[vertex_id]]) {
    const float2 corners[3] = { float2(-1, -1), float2(3, -1), float2(-1, 3) };
    return GlobeVertex { float4(corners[id], 0, 1) };
}

static float2 textureCoordinate(float3 normal, float centreLongitude, float tilt) {
    float y = normal.y * cos(tilt) + normal.z * sin(tilt);
    float z = -normal.y * sin(tilt) + normal.z * cos(tilt);
    float longitude = atan2(normal.x, z) + centreLongitude;
    float latitude = asin(clamp(y, -1.0, 1.0));
    return float2(fract(longitude / (2 * M_PI_F) + 0.5), 0.5 - latitude / M_PI_F);
}

static float3 surfaceColour(float3 normal, float3 sun, float3 day, float3 night) {
    float facing = dot(normal, sun);
    float lit = smoothstep(-0.08, 0.25, facing);

    float3 daylight = day * (0.06 + 1.05 * saturate(facing + 0.05));
    daylight += duskColour * exp(-abs(facing) * 9) * smoothstep(-0.2, 0.05, facing) * 0.18;

    float water = smoothstep(0.03, 0.12, day.b - max(day.r, day.g));
    float glint = pow(max(dot(reflect(-sun, normal), float3(0, 0, 1)), 0.0), 28.0) * water * 0.55 * lit;

    float brightness = dot(night, float3(0.3, 0.59, 0.11));
    float cityLight = smoothstep(0.07, 0.4, brightness);
    float3 lights = night * cityLightColour * 2.4 * cityLight * (1 - smoothstep(-0.18, 0.06, facing));
    float3 darkness = brightness * moonlitLandColour * (1 - cityLight) + float3(0, 0.005, 0.015);

    float3 colour = mix(darkness + lights, daylight + glint * glintColour, lit);
    float rim = pow(1 - normal.z, 3.0);
    return colour + atmosphereColour * rim * 0.6 * smoothstep(-0.3, 0.4, facing);
}

fragment float4 globeFragment(GlobeVertex in [[stage_in]],
                              constant GlobeUniforms &uniforms [[buffer(0)]],
                              texture2d<float> dayTexture [[texture(0)]],
                              texture2d<float> nightTexture [[texture(1)]]) {
    constexpr sampler earth(filter::linear, mip_filter::linear, s_address::repeat, t_address::clamp_to_edge, max_anisotropy(8));

    float radius = uniforms.size.z;
    float2 point = (in.position.xy - uniforms.size.xy * 0.5) / radius;
    point.y = -point.y;
    float distance = length(point);
    float2 onSphere = distance > 1 ? point / distance : point;
    float3 normal = float3(onSphere, sqrt(max(0.0, 1 - dot(onSphere, onSphere))));
    float3 sun = uniforms.sun.xyz;

    float2 uv = textureCoordinate(normal, uniforms.orientation.x, uniforms.orientation.y);
    float2 dx = dfdx(uv);
    float2 dy = dfdy(uv);
    dx.x -= round(dx.x);
    dy.x -= round(dy.x);
    float3 day = dayTexture.sample(earth, uv, gradient2d(dx, dy)).rgb;
    float3 night = nightTexture.sample(earth, uv, gradient2d(dx, dy)).rgb;

    float coverage = saturate((1 - distance) * radius + 0.5);
    float3 globe = surfaceColour(normal, sun, day, night);

    float height = (distance - 1) / atmosphereThickness;
    float haloLight = smoothstep(-0.4, 0.5, dot(float3(normalize(point), 0), sun));
    float halo = distance > 1 ? pow(saturate(1 - height), 2.0) * 0.55 * (0.15 + 0.85 * haloLight) : 0;

    float alpha = coverage + halo * (1 - coverage);
    float3 colour = globe * coverage + atmosphereColour * halo * (1 - coverage);
    return float4(colour, alpha);
}
