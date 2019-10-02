# Scale pixel to cm
Ce projet à été développé dans le cadre d'un stage de master informatique spécialité AVR (Apprentissage Vision Robotique). Il permet de calculer la taille d'un pixel en cm.
## Dépendances
Voici la liste des dépendances nécessaire au bon fonctionnement du projet.
- Python 3
- Scikit-image
- numpy 1.16.2
- OpenCV
- Pillow
- Virtualenv
- Keras
- TensorFlow
## Fonctionnement
Deux scripts (compute_scale/writeScale.sh et compute_scale/clean.sh) permettent de faire fonctionner le projet facilement.
### writeScale.sh
Ce script prend en entrée un répertoire contenant des images et le nom du fichier résultat. Il écrit l'échelle de conversion de pixel à cm dans le fichier résultat sous la forme : "nom de l'image | échelle". échelle est le nombre de pixel le long d'un côté du damier. 
  ```
  ./writeScale.sh <Path to your images>  <name of output file>
  ```
