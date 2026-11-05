#version 450

#pragma stage vertex

layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

layout(set = 0, binding = 0) uniform UBO {
    mat4 MVP;
    vec4 OutputSize;
    vec4 FinalViewportSize;
    vec4 SourceSize;
} global;

void main() {
    gl_Position = global.MVP * Position;
    vTexCoord = TexCoord;
}

#pragma stage fragment

layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;

layout(set = 0, binding = 0) uniform UBO {
    mat4 MVP;
    vec4 OutputSize;
    vec4 FinalViewportSize;
    vec4 SourceSize;
} global;

layout(set = 0, binding = 1) uniform sampler2D Source;

const vec3 GOLD = vec3(245.0, 196.0, 81.0) / 255.0;
const vec3 RED  = vec3(230.0, 57.0, 70.0) / 255.0;

// Adjust these to change the effect.
const float GLOW_STRENGTH = 0.65;
const float GLOW_RADIUS = 2.0;
const float COLOR_TOLERANCE = 0.24;

float colourMatch(vec3 pixel, vec3 target) {
    float distanceFromTarget = distance(pixel, target);
    return 1.0 - smoothstep(
        COLOR_TOLERANCE * 0.35,
        COLOR_TOLERANCE,
        distanceFromTarget
    );
}

vec3 glowSource(vec3 pixel) {
    float goldMatch = colourMatch(pixel, GOLD);
    float redMatch = colourMatch(pixel, RED);

    return GOLD * goldMatch + RED * redMatch;
}

void main() {
    vec4 original = texture(Source, vTexCoord);

    vec2 texel = 1.0 / global.SourceSize.xy;

    vec3 glow = vec3(0.0);
    float totalWeight = 0.0;

    // Sample neighbouring pixels to create bloom.
    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            vec2 offset = vec2(float(x), float(y));

            float weight = exp(
                -dot(offset, offset) / 12.0
            );

            vec2 uv = vTexCoord +
                offset * texel * GLOW_RADIUS;

            vec3 sampleColour = texture(Source, uv).rgb;

            glow += glowSource(sampleColour) * weight;
            totalWeight += weight;
        }
    }

    glow /= totalWeight;

    // Add the glow without blurring the original text.
    vec3 result = original.rgb + glow * GLOW_STRENGTH;

    FragColor = vec4(min(result, vec3(1.0)), original.a);
}
