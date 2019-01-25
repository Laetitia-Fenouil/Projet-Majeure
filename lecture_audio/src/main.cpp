/*****************************************************************************\
 * TP CPE, 3ETI, TP synthese d'images
 * --------------
 *
 * Programme principal des appels OpenGL
\*****************************************************************************/
#include "fmod/inc/fmod.hpp"
#include "fmod/common.h"

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <cmath>

#define GLEW_STATIC 1
#include <GL/glew.h>
#include <GL/glut.h>

#include "glutils.hpp"

#include "mat4.hpp"
#include "vec3.hpp"
#include "vec2.hpp"
#include "triangle_index.hpp"
#include "vertex_opengl.hpp"
#include "image.hpp"
#include "mesh.hpp"


/*****************************************************************************\
 * Variables globales
 *
 *
\*****************************************************************************/

//identifiant du shader
GLuint shader_program_id;

//identifiants pour object 1
GLuint vbo_object_1=0;
GLuint vboi_object_1=0;
GLuint texture_id_object_1=0;
int nbr_triangle_object_1;

//identifiants pour object 2
GLuint vbo_object_2=0;
GLuint vboi_object_2=0;
GLuint texture_id_object_2=0;
int nbr_triangle_object_2;

//identifiants pour object 3
GLuint vbo_object_3=0;
GLuint vboi_object_3=0;
GLuint texture_id_object_3=0;
int nbr_triangle_object_3;

struct song_properties
{
    std::vector<int> F1;
    std::vector<int> F2;
    std::vector<int> F3;

    std::vector<float> A1;
    std::vector<float> A2;
    std::vector<float> A3;
    std::vector<float> B;
    std::vector<float> V;

    int BPM;
    int NSample;
    float Dt;
    bool isSet;
    std::string file;
    song_properties(){
        isSet = false;
    }

};


//Matrice de transformation
struct transformation
{
    mat4 rotation;
    vec3 rotation_center;
    vec3 translation;

    transformation():rotation(),rotation_center(),translation(){}
};

//Transformation des modeles
transformation transformation_model_1;
transformation transformation_model_2;
transformation transformation_model_3;

//Transformation de la vue (camera)
transformation transformation_view;

//Matrice de projection
mat4 projection;

//angle de deplacement
float angle_x_model_1 = 0.0f;
float angle_y_model_1 = 0.0f;
float angle_view = 0.0f;

//timer
int t = 0;
int t_callback = 30;
int t_sample = 30;
int true_t_sample = (t_sample/t_callback)*t_callback;
float mod_ampl = 1./(((float)true_t_sample/(float)t_callback)/2.);

//frequence/pic (done)
int i_tableau_freq = 0;
song_properties properties;
float frequence = 0;
float frequence2 = 0;
float frequence3 = 0;
float amplitude = 0;
float amplitude2 = 0;
float amplitude3 = 0;
float timer_amplitude = 0;
int t_a_neg = 1;
bool protection = 0;
bool reset_t_amp = 0;

//battement/grosseur
float battement = 0;

//BPM/lumiere (done)
float bitpermin = 120;
float lightBit;
int speed = 1/(((float)bitpermin/60000.)*(float)t_callback);
int countDir = 1;

//couleur (to specify/to do)
int countColor = 0;
int batpermin = 239;

//fonctions
void init_model_1();
void draw_model_1();

void parse_file(int argc, char** argv);

void fill_vector_int(std::string line, std::vector<int>& vec_data);
void fill_vector_float(std::string line, std::vector<float>& vec_data);

static void init()
{

    // Chargement du shader
    shader_program_id = read_shader("shader.vert", "shader.frag");

    //matrice de projection
    projection = matrice_projection(60.0f*M_PI/180.0f,1.0f,0.01f,100.0f);
    glUniformMatrix4fv(get_uni_loc(shader_program_id,"projection"),1,false,pointeur(projection)); PRINT_OPENGL_ERROR();

    //centre de rotation de la 'camera' (les objets sont centres en z=-2)
    transformation_view.rotation_center = vec3(0.0f,0.0f,-2.0f);

    //activation de la gestion de la profondeur
    glEnable(GL_DEPTH_TEST); PRINT_OPENGL_ERROR();

    // Charge modele 1 sur la carte graphique
    init_model_1();

}


//Fonction d'affichage
static void display_callback()
{
    //effacement des couleurs du fond d'ecran
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);                 PRINT_OPENGL_ERROR();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);   PRINT_OPENGL_ERROR();

    // Affecte les parametres uniformes de la vue (identique pour tous les modeles de la scene)
    {
        //envoie de la rotation
        glUniformMatrix4fv(get_uni_loc(shader_program_id,"rotation_view"),1,false,pointeur(transformation_view.rotation)); PRINT_OPENGL_ERROR();

        //envoie du centre de rotation
        vec3 cv = transformation_view.rotation_center;
        glUniform4f(get_uni_loc(shader_program_id,"rotation_center_view") , cv.x,cv.y,cv.z , 0.0f); PRINT_OPENGL_ERROR();

        //envoie de la translation
        vec3 tv = transformation_view.translation;
        glUniform4f(get_uni_loc(shader_program_id,"translation_view") , tv.x,tv.y,tv.z , 0.0f); PRINT_OPENGL_ERROR();

        //envoie la fréquence et l'amplitude
        glUniform3f(get_uni_loc(shader_program_id,"frequence") , frequence, frequence2, frequence3); PRINT_OPENGL_ERROR();
        glUniform3f(get_uni_loc(shader_program_id,"amplitude") , amplitude, amplitude2, amplitude3); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id, "beat"), battement); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id,"lightBit") , lightBit); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id,"batpermin") , batpermin); PRINT_OPENGL_ERROR();

    }

    // Affiche le modele numero 1
    draw_model_1();

    //Changement de buffer d'affichage pour eviter un effet de scintillement
    glutSwapBuffers();
}



/*****************************************************************************\
 * keyboard_callback                                                         *
\*****************************************************************************/
static void keyboard_callback(unsigned char key, int, int)
{
    float d_angle=0.1f;
    float dz=0.5f;

    //quitte le programme si on appuie sur les touches 'q', 'Q', ou 'echap'
    switch (key)
    {
    case 'q':
    case 'Q':
    case 27:
        exit(0);
        break;

    case 'o':
        angle_x_model_1 += d_angle;
        break;
    case 'l':
        angle_x_model_1 -= d_angle;
        break;

    case 'k':
        angle_y_model_1 += d_angle;
        break;
    case 'm':
        angle_y_model_1 -= d_angle;
        break;


    case 's':
        angle_view += d_angle;
        break;
    case 'f':
        angle_view -= d_angle;
        break;


    case 'e':
        transformation_view.translation.z += dz;
        break;
    case 'd':
        transformation_view.translation.z -= dz;
        break;

    }

    transformation_model_1.rotation = matrice_rotation(angle_y_model_1 , 0.0f,1.0f,0.0f) * matrice_rotation(angle_x_model_1 , 1.0f,0.0f,0.0f);
    transformation_view.rotation = matrice_rotation(angle_view , 0.0f,1.0f,0.0f);
}

/*****************************************************************************\
 * special_callback                                                          *
\*****************************************************************************/
static void special_callback(int key, int,int)
{
    float dL=0.03f;
    switch (key)
    {
    case GLUT_KEY_UP:
        transformation_model_1.translation.y += dL; //rotation avec la touche du haut
        break;
    case GLUT_KEY_DOWN:
        transformation_model_1.translation.y -= dL; //rotation avec la touche du bas
        break;
    case GLUT_KEY_LEFT:
        transformation_model_1.translation.x -= dL; //rotation avec la touche de gauche
        break;
    case GLUT_KEY_RIGHT:
        transformation_model_1.translation.x += dL; //rotation avec la touche de droite
        break;
    }

    //reactualisation de l'affichage
    glutPostRedisplay();
}


/*****************************************************************************\
 * timer_callback                                                            *
\*****************************************************************************/
static void timer_callback(int)
{
    t += t_callback;
    if((float)t/(float)true_t_sample >= 1) {
        i_tableau_freq = i_tableau_freq+1;
        if(i_tableau_freq>properties.NSample)
            exit(0);
        t = t_sample - t;
        protection = 0;
        t_a_neg = -1*t_a_neg;
        reset_t_amp = 1;
        countColor = countColor + 1;
        if(countColor == (int)(properties.NSample/240.)) {
            batpermin = batpermin - 1;
            countColor = 0;
        }
    }

    if(t >= true_t_sample/2 && protection == 0) {
        t_a_neg = -1*t_a_neg;
        protection = 1;
    }

    if(reset_t_amp == 1){
        timer_amplitude = 0;
        reset_t_amp = 0;
    }
    else
        timer_amplitude = timer_amplitude + (float)t_a_neg*mod_ampl;

    frequence = properties.F1[i_tableau_freq];
    frequence2 = properties.F2[i_tableau_freq];
    frequence3 = properties.F3[i_tableau_freq];
    amplitude = properties.A1[i_tableau_freq];
    if(frequence2 == frequence)
        amplitude2 = 0;
    else
        amplitude2 = properties.A2[i_tableau_freq];
    if(frequence3 == frequence2 || frequence3 == frequence)
        amplitude3 = 0;
    else
        amplitude3 = properties.A3[i_tableau_freq];
    battement = properties.B[i_tableau_freq];

    lightBit = lightBit + 2.*(float)countDir/(float)speed;
    if((lightBit >= 1 && countDir == 1)|| (lightBit <= -1  && countDir == -1))
        countDir = -1*countDir;

    batpermin = properties.V[i_tableau_freq];

    //reactualisation de l'affichage
    glutPostRedisplay();

    //demande de rappel de cette fonction dans 20ms
    glutTimerFunc(t_callback, timer_callback, 0);
}

int main(int argc, char** argv)
{

    FMOD::System     *system;
    FMOD::Sound      *sound1;
    FMOD::Channel    *channel = 0;
    FMOD_RESULT       result;
    unsigned int      version;
    void             *extradriverdata = 0;

    parse_file(argc, argv);

    bitpermin = properties.BPM;
    speed = 1/(((float)bitpermin/60000.)*(float)t_callback);

    Common_Init(&extradriverdata);

    result = System_Create(&system);
    ERRCHECK(result);

    result = system->getVersion(&version);
    ERRCHECK(result);

    if (version < FMOD_VERSION)
    {
        Common_Fatal("FMOD lib version %08x doesn't match header version %08x", version, FMOD_VERSION);
    }

    result = system->init(32, FMOD_INIT_NORMAL, extradriverdata);
    ERRCHECK(result);

    std::cout<<properties.file.c_str()<<std::endl;
    result = system->createSound(properties.file.c_str(), FMOD_DEFAULT, 0, &sound1);
    ERRCHECK(result);

    lightBit = -1;

    //**********************************************//
    //Lancement des fonctions principales de GLUT
    //**********************************************//

    //initialisation
    glutInit(&argc, argv);

    //Mode d'affichage (couleur, gestion de profondeur, ...)
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);

    //Taille de la fenetre a l'ouverture
    glutInitWindowSize(600, 600);

    //Titre de la fenetre
    glutCreateWindow("OpenGL");

    //Fonction de la boucle d'affichage
    glutDisplayFunc(display_callback);

    //Fonction de gestion du clavier
    glutKeyboardFunc(keyboard_callback);

    //Fonction des touches speciales du clavier (fleches directionnelles)
    glutSpecialFunc(special_callback);

    //Fonction d'appel d'affichage en chaine
    glutTimerFunc(t_callback, timer_callback, 0);

    //Initialisation des fonctions OpenGL
    glewInit();

    //Notre fonction d'initialisation des donnees et chargement des shaders
    init();


    result = system->playSound(sound1, 0, false, &channel);
    ERRCHECK(result);

    //Lancement de la boucle (infinie) d'affichage de la fenetre
    glutMainLoop();

    //Plus rien n'est execute apres cela

    return 0;
}


void draw_model_1()
{

    //envoie des parametres uniformes
    {
        glUniformMatrix4fv(get_uni_loc(shader_program_id,"rotation_model"),1,false,pointeur(transformation_model_1.rotation));    PRINT_OPENGL_ERROR();

        vec3 c = transformation_model_1.rotation_center;
        glUniform4f(get_uni_loc(shader_program_id,"rotation_center_model") , c.x,c.y,c.z , 0.0f);                                 PRINT_OPENGL_ERROR();

        vec3 t = transformation_model_1.translation;
        glUniform4f(get_uni_loc(shader_program_id,"translation_model") , t.x,t.y,t.z , 0.0f);                                     PRINT_OPENGL_ERROR();

        //envoie la fréquence et l'amplitude
        glUniform3f(get_uni_loc(shader_program_id,"frequence") , frequence, frequence2, frequence3); PRINT_OPENGL_ERROR();
        glUniform3f(get_uni_loc(shader_program_id,"amplitude") , amplitude, amplitude2, amplitude3); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id, "beat"), battement); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id,"lightBit") , lightBit); PRINT_OPENGL_ERROR();
        glUniform1f(get_uni_loc(shader_program_id,"batpermin") , batpermin); PRINT_OPENGL_ERROR();

    }

    //placement des VBO
    {
        //selection du VBO courant
        glBindBuffer(GL_ARRAY_BUFFER,vbo_object_1);                                                    PRINT_OPENGL_ERROR();

        // mise en place des differents pointeurs
        glEnableClientState(GL_VERTEX_ARRAY);                                                          PRINT_OPENGL_ERROR();
        glVertexPointer(3, GL_FLOAT, sizeof(vertex_opengl), 0);                                        PRINT_OPENGL_ERROR();

        glEnableClientState(GL_NORMAL_ARRAY); PRINT_OPENGL_ERROR();                                    PRINT_OPENGL_ERROR();
        glNormalPointer(GL_FLOAT, sizeof(vertex_opengl), buffer_offset(sizeof(vec3)));                 PRINT_OPENGL_ERROR();

        glEnableClientState(GL_COLOR_ARRAY); PRINT_OPENGL_ERROR();                                     PRINT_OPENGL_ERROR();
        glColorPointer(3,GL_FLOAT, sizeof(vertex_opengl), buffer_offset(2*sizeof(vec3)));              PRINT_OPENGL_ERROR();

        glEnableClientState(GL_TEXTURE_COORD_ARRAY); PRINT_OPENGL_ERROR();                             PRINT_OPENGL_ERROR();
        glTexCoordPointer(2,GL_FLOAT, sizeof(vertex_opengl), buffer_offset(3*sizeof(vec3)));           PRINT_OPENGL_ERROR();

    }

    //affichage
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,vboi_object_1);                           PRINT_OPENGL_ERROR();
        glBindTexture(GL_TEXTURE_2D, texture_id_object_1);                             PRINT_OPENGL_ERROR();
        glDrawElements(GL_TRIANGLES, 3*nbr_triangle_object_1, GL_UNSIGNED_INT, 0);     PRINT_OPENGL_ERROR();
    }

}


void init_model_1()
{
    // Chargement d'un maillage a partir d'un fichier
    mesh m = load_obj_file("../data/sphere.obj");

    // Affecte une transformation sur les sommets du maillage
    float s = 1.;
    mat4 transform = mat4(   s, 0.0f, 0.0f, 0.0f,
                          0.0f,    s, 0.0f, 0.0f,
                          0.0f, 0.0f,   s , 0.0f,
                          0.0f, 0.0f, 0.0f, 1.0f);
    apply_deformation(&m,transform);

    // Centre la rotation du modele 1 autour de son centre de gravite approximatif
    transformation_model_1.rotation_center = vec3(0.0f,-0.0f,-0.0f);

    // Calcul automatique des normales du maillage
    update_normals(&m);
    // Les sommets sont affectes a une couleur blanche
    fill_color(&m,vec3(0.8f,0.0f,1.0f));

    //attribution d'un buffer de donnees (1 indique la création d'un buffer)
    glGenBuffers(1,&vbo_object_1); PRINT_OPENGL_ERROR();
    //affectation du buffer courant
    glBindBuffer(GL_ARRAY_BUFFER,vbo_object_1); PRINT_OPENGL_ERROR();
    //copie des donnees des sommets sur la carte graphique
    glBufferData(GL_ARRAY_BUFFER,m.vertex.size()*sizeof(vertex_opengl),&m.vertex[0],GL_STATIC_DRAW); PRINT_OPENGL_ERROR();


    //attribution d'un autre buffer de donnees
    glGenBuffers(1,&vboi_object_1); PRINT_OPENGL_ERROR();
    //affectation du buffer courant (buffer d'indice)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,vboi_object_1); PRINT_OPENGL_ERROR();
    //copie des indices sur la carte graphique
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,m.connectivity.size()*sizeof(triangle_index),&m.connectivity[0],GL_STATIC_DRAW); PRINT_OPENGL_ERROR();

    // Nombre de triangles de l'objet 1
    nbr_triangle_object_1 = m.connectivity.size();


}


void fill_vector_int(std::string line, std::vector<int>& vec_data){

    std::string value;
    std::size_t separator_ind = line.find('-');
    while(separator_ind != std::string::npos){
        value = line.substr(0, separator_ind);
        line = line.substr(separator_ind + 1, line.size() - (int) separator_ind);
        vec_data.push_back(std::atoi(value.c_str()));
        separator_ind = line.find('-');
    }
    vec_data.push_back(std::atoi(line.c_str()));

}

void fill_vector_float(std::string line, std::vector<float>& vec_data){

    std::string value;
    std::size_t separator_ind = line.find('-');
    while(separator_ind != std::string::npos){
        value = line.substr(0, separator_ind);
        line = line.substr(separator_ind + 1, line.size() - (int) separator_ind);
        vec_data.push_back(std::atof(value.c_str()));
        separator_ind = line.find('-');
    }
    vec_data.push_back(std::atof(line.c_str()));

}

void parse_file(int argc, char** argv){

    std::string line;
    std::cout<<properties.F1.size()<<" "<<properties.F2.size()<<" "<<properties.F3.size()<<" "<<properties.A1.size()<<" "<<properties.A2.size()<<" "<<properties.A3.size()<<" "<<properties.B.size()<<std::endl;
    if(argc<2)
        return;
    std::cout<<properties.F1.size()<<" "<<properties.F2.size()<<" "<<properties.F3.size()<<" "<<properties.A1.size()<<" "<<properties.A2.size()<<" "<<properties.A3.size()<<" "<<properties.B.size()<<std::endl;
    std::ifstream myfile(argv[1]);
    if (myfile)
    {
        std::cout<<"fichier ouvert"<<std::endl;

        while (getline(myfile, line))
        {
            std::size_t h_sep_ind = line.find_first_of(":");
            std::string  header = line.substr(0, h_sep_ind);
            std::string values_to_parse = line.substr(h_sep_ind + 1, line.size() - (int) h_sep_ind);
            std::cout<<header<<std::endl;

            if(header.compare("file") == 0){

                properties.file = values_to_parse.substr(0, values_to_parse.size());

            } else if(header.compare("NSample") == 0){

                properties.NSample = std::atoi(values_to_parse.c_str());
                std::cout<<header<<std::endl;


            } else if(header.compare("Dt") == 0){

                properties.Dt = std::atof(values_to_parse.c_str());
                std::cout<<header<<std::endl;


            } else if(header.compare("BPM") == 0){

                properties.BPM = std::atoi(values_to_parse.c_str());
                std::cout<<header<<std::endl;


            } else if(header.compare("F1") == 0){

                fill_vector_int(values_to_parse, properties.F1);
                std::cout<<header<<std::endl;


            } else if(header.compare("F2") == 0){

                fill_vector_int(values_to_parse, properties.F2);
                std::cout<<header<<std::endl;


            } else if(header.compare("F3") == 0){

                fill_vector_int(values_to_parse, properties.F3);
                std::cout<<header<<std::endl;


            } else if(header.compare("B") == 0){

                fill_vector_float(values_to_parse, properties.B);
                std::cout<<header<<std::endl;


            } else if(header.compare("A1") == 0){

                fill_vector_float(values_to_parse, properties.A1);
                std::cout<<header<<std::endl;


            } else if(header.compare("A2") == 0){

                fill_vector_float(values_to_parse, properties.A2);
                std::cout<<header<<std::endl;


            } else if(header.compare("A3") == 0){

                fill_vector_float(values_to_parse, properties.A3);
                std::cout<<header<<std::endl;


            } else if(header.compare("V") == 0){

                fill_vector_float(values_to_parse, properties.V);
                std::cout<<header<<std::endl;
            } else if(header.compare("Dt") == 0){

//                t_sample = 1000*std::atoi(values_to_parse.c_str());
//                t_callback = t_sample;
//                true_t_sample = (t_sample/t_callback)*t_callback;
//                mod_ampl = 1./(((float)true_t_sample/(float)t_callback)/2.);

            }
        }
        properties.isSet = true;
        std::cout<<properties.F1.size()<<" "<<properties.F2.size()<<" "<<properties.F3.size()<<" "<<properties.A1.size()<<" "<<properties.A2.size()<<" "<<properties.A3.size()<<" "<<properties.B.size()<<std::endl;

        myfile.close();
    }
}
