#version 120

varying vec3 coordonnee_3d;
varying vec3 coordonnee_3d_locale;
varying vec3 normale;
varying vec4 color;

vec3 light = vec3(0.,5.,0.);
vec3 light2 = vec3(0.,-5.,0.);
vec3 light3 = vec3(5.,0.,0.);
vec3 light4 = vec3(-5.,0.,0.);
uniform float lightBit;
uniform float batpermin;

void main (void)
{
    light.x = -5.*lightBit;

    //vecteurs pour le calcul d'illumination light
    vec3 n = normalize(normale);
    vec3 d = normalize(light-coordonnee_3d_locale);
    vec3 r = reflect(d,n);
    vec3 o = normalize(-coordonnee_3d_locale);

    light2.x = 5.*lightBit;

    //vecteurs pour le calcul d'illumination light2
    vec3 n2 = normalize(normale);
    vec3 d2 = normalize(light2-coordonnee_3d_locale);
    vec3 r2 = reflect(d2,n2);
    vec3 o2 = normalize(-coordonnee_3d_locale);

    light3.y = -5.*lightBit;

    //vecteurs pour le calcul d'illumination light3
    vec3 n3 = normalize(normale);
    vec3 d3 = normalize(light3-coordonnee_3d_locale);
    vec3 r3 = reflect(d3,n3);
    vec3 o3 = normalize(-coordonnee_3d_locale);

    light4.y = 5.*lightBit;

    //vecteurs pour le calcul d'illumination light4
    vec3 n4 = normalize(normale);
    vec3 d4 = normalize(light4-coordonnee_3d_locale);
    vec3 r4 = reflect(d4,n4);
    vec3 o4 = normalize(-coordonnee_3d_locale);

    //calcul d'illumination light
    float diffuse  = 0.2*clamp(dot(n,d),0.0,1.0);
    float specular = 0.8*pow(clamp(dot(r,o),0.0,1.0),128.0);
    float ambiant  = 0.1;

    //calcul d'illumination light2
    float diffuse2  = 0.2*clamp(dot(n2,d2),0.0,1.0);
    float specular2 = 0.8*pow(clamp(dot(r2,o2),0.0,1.0),128.0);
    float ambiant2  = 0.1;

    //calcul d'illumination light
    float diffuse3  = 0.2*clamp(dot(n3,d3),0.0,1.0);
    float specular3 = 0.8*pow(clamp(dot(r3,o3),0.0,1.0),128.0);
    float ambiant3  = 0.1;

    //calcul d'illumination light2
    float diffuse4  = 0.2*clamp(dot(n4,d4),0.0,1.0);
    float specular4 = 0.8*pow(clamp(dot(r4,o4),0.0,1.0),128.0);
    float ambiant4  = 0.1;

    vec4 white = vec4(1.0,1.0,1.0,0.0);

    //calcul couleur
    float Rprime, Gprime, Bprime;
    if(batpermin < 60) {
        Rprime = 1.;
        Gprime = 1-abs(mod(batpermin/60,2)-1);
        Bprime = 0.;
    }
    else if(batpermin < 120) {
        Rprime = 1-abs(mod(batpermin/60,2)-1);
        Gprime = 1.;
        Bprime = 0.;
    }
    else if(batpermin < 180) {
        Rprime = 0.;
        Gprime = 1.;
        Bprime = 1-abs(mod(batpermin/60,2)-1);
    }
    else if(batpermin < 240) {
        Rprime = 0.;
        Gprime = 1-abs(mod(batpermin/60,2)-1);
        Bprime = 1.;
    }
    else {
        Rprime = 0.;
        Gprime = 1.;
        Bprime = 1.;
    }

    vec4 color_final   = color;
    color_final.r = Rprime;
    color_final.g = Gprime;
    color_final.b = Bprime;

    //couleur finale
    gl_FragColor = (ambiant+diffuse)*color_final+specular*white + (ambiant2+diffuse2)*color_final+specular2*white + (ambiant3+diffuse3)*color_final+specular3*white + (ambiant4+diffuse4)*color_final+specular4*white;
}
