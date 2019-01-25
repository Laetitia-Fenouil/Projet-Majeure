#version 120

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 projection;
uniform mat4 modelview;

varying vec3 coordonnee_3d;
varying vec3 coordonnee_3d_locale;
varying vec3 normale;
varying vec4 color;

void main(void)
{
  for (int i = 0; i < 3; i++)
  {
    gl_Position = gl_Position;
    // ou : gl_Position = gl_in[i].gl_Position;
    EmitVertex();
  }
  EndPrimitive();
}
