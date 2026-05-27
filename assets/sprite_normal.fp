#version 140

// https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6

// attributes from vertex shader
in mediump vec2 var_texcoord0;
in mediump vec2 var_texcoord1;

// our texture samplers
uniform sampler2D diffuse;   // diffuse map
uniform sampler2D normal;    // normal map

// values used for shading algorithm...
uniform fs_uniforms {
    vec4 resolution;      // resolution of screen
    vec4 light_pos;       // light position, normalized
    vec4 light_color;     // light RGBA -- alpha is intensity
    vec4 ambient_color;   // ambient RGBA -- alpha is intensity
    vec4 falloff;         // attenuation coefficients
};

out vec4 out_fragColor;

void main() {
    // RGBA of our diffuse color
    vec4 diffuse_rgba = texture(diffuse, var_texcoord0);

    // RGB of our normal map
    vec3 normal_rgb = texture(normal, var_texcoord1).rgb;

    // the delta position of light
    vec3 light_dir = vec3(light_pos.xy - (gl_FragCoord.xy / resolution.xy), light_pos.z);

    // correct for aspect ratio
    light_dir.x *= resolution.x / resolution.y;

    // determine distance (used for attenuation) BEFORE we normalize our light_dir
    float D = length(light_dir);

    // normalize our vectors
    vec3 N = normalize(normal_rgb * 2.0 - 1.0);
    vec3 L = normalize(light_dir);

    // pre-multiply light color with intensity
    // then perform "N dot L" to determine our diffuse term
    vec3 diffuse = (light_color.rgb * light_color.a) * max(dot(N, L), 0.0);

    // pre-multiply ambient color with intensity
    vec3 ambient = ambient_color.rgb * ambient_color.a;

    // calculate attenuation
    float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
    //attenuation = 0.5;

    // the calculation which brings it all together
    vec3 intensity = ambient + diffuse * attenuation;
    vec3 final_color = diffuse_rgba.rgb * intensity;
    out_fragColor = vec4(final_color, diffuse_rgba.a);
}