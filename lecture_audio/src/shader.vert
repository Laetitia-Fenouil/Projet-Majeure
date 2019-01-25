#version 120

uniform mat4 rotation_model;
uniform vec4 rotation_center_model;
uniform vec4 translation_model;

uniform mat4 rotation_view;
uniform vec4 rotation_center_view;
uniform vec4 translation_view;

uniform mat4 projection;

uniform vec3 frequence;
uniform vec3 amplitude;
uniform float beat;

varying vec3 coordonnee_3d;
varying vec3 coordonnee_3d_locale;
varying vec3 normale;
varying vec4 color;


//Un Vertex Shader minimaliste
void main (void)
{
    vec4 p = gl_Vertex ;
    float R = length(p);

    float M_PI = 3.1415926535897932384626433832795;

    float theta_th = (((frequence.x-20)/9990)-1.)*(M_PI/2);
    theta_th = M_PI*log(theta_th + 0.5*M_PI)/log(M_PI) - 0.5*M_PI;
    vec3 p_th = R*vec3(cos(theta_th), sin(theta_th), 0);
    vec3 n_th = normalize((p_th));
    float theta_p = acos(dot(n_th, gl_Normal));
    float hmax1 = 1+200*amplitude.x;
    if(hmax1 > 2.3)
        hmax1 = 2.3;

    float theta_th2 = (((frequence.y-20)/9990)-1.)*(M_PI/2);
    theta_th2 = M_PI*log(theta_th2 + 0.5*M_PI)/log(M_PI) - 0.5*M_PI;
    vec3 p_th2 = R*vec3(cos(theta_th2), sin(theta_th2), 0);
    vec3 n_th2 = normalize((p_th2));
    float theta_p2 = acos(dot(n_th2, gl_Normal));
    float hmax2 = 1+200*amplitude.y;
    if(hmax2 > 2.3)
        hmax2 = 2.3;

    float theta_th3 = (((frequence.z-20)/9990)-1.)*(M_PI/2);
    theta_th3 = M_PI*log(theta_th3 + 0.5*M_PI)/log(M_PI) - 0.5*M_PI;
    vec3 p_th3 = R*vec3(cos(theta_th3), sin(theta_th3), 0);
    vec3 n_th3 = normalize((p_th3));
    float theta_p3 = acos(dot(n_th3, gl_Normal));
    float hmax3 = 1+200*amplitude.z;
    if(hmax3 > 2.3)
        hmax3 = 2.3;

    float theta_max = (10*M_PI)/(2*360);
    float alpha = 0;
    float hmax = 0;
    if(theta_p < theta_max){
        alpha = (theta_max - theta_p)/theta_max;
        hmax = hmax1;
    }
    else if(theta_p2 < theta_max){
        alpha = (theta_max - theta_p2)/theta_max;
        hmax = hmax2;
    }
    else if(theta_p3 < theta_max){
        alpha = (theta_max - theta_p3)/theta_max;
        hmax = hmax3;
    }
    // hmin = 1
    float h = alpha * hmax + (1-alpha);
    p.xy = p.xy*h;

    // calcul pour le pic symétrique
    n_th = normalize(vec3(cos(M_PI - theta_th), sin(M_PI - theta_th), 0));
    theta_p = acos(dot(n_th, gl_Normal));

    n_th2 = normalize(vec3(cos(M_PI - theta_th2), sin(M_PI - theta_th2), 0));
    theta_p2 = acos(dot(n_th2, gl_Normal));

    n_th3 = normalize(vec3(cos(M_PI - theta_th3), sin(M_PI - theta_th3), 0));
    theta_p3 = acos(dot(n_th3, gl_Normal));

    alpha = 0;
    if(theta_p < theta_max){
        alpha = (theta_max - theta_p)/theta_max;
        hmax = hmax1;
    }
    else if(theta_p2 < theta_max){
        alpha = (theta_max - theta_p2)/theta_max;
        hmax = hmax2;
    }
    else if(theta_p3 < theta_max){
        alpha = (theta_max - theta_p3)/theta_max;
        hmax = hmax3;
    }
    // hmin = 1
    if(length(p) > R){
        float h1 = alpha * hmax + (1-alpha);
        p.xy = p.xy/h;
        h = max(h1, h);
    }else
        h = alpha * hmax + (1-alpha);
    p.xy = p.xy*h;
    p.z = p.z-4;

    p.xy = p.xy*(1+beat/1000);

    //Les coordonnees 3D du sommet
    coordonnee_3d = p.xyz;


    //application de la deformation du model
    vec4 p_model = rotation_model*(p-rotation_center_model)+rotation_center_model+translation_model;
    //application de la deformation de la vue
    vec4 p_modelview = rotation_view*(p_model-rotation_center_view)+rotation_center_view+translation_view;

    coordonnee_3d_locale = p_modelview.xyz;


    //Projection du sommet
    vec4 p_proj = projection*p_modelview;

    //Gestion des normales
    vec4 n = rotation_view*rotation_model*vec4(gl_Normal,0.0);
    normale = n.xyz;

    //Couleur du sommet
    color=gl_Color;

    //position dans l'espace ecran
    gl_Position = p_proj;

    //coordonnees de textures
    gl_TexCoord[0]=gl_MultiTexCoord0;
}
