# Conversion de pixel à cm
Ce projet a été développé dans le cadre d'un stage de master informatique spécialité AVR (Apprentissage Vision Robotique). Il permet de calculer la taille d'un pixel en cm dans des images contenant un damier de taille 2*13. Cela rend possible des mesures géométriques tel que la surface ou le diamètre sur des grumes de bois. Un plugin ImageJ a été développé pour faire des mesures en cm. Ci-dessous un schéma qui explique à quoi sert ce projet.

![alt text](recap.png?raw=true "A quoi ça sert ?")
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
- MATLAB R2019a
- DGtal

## Fonctionnement
Deux scripts (*compute_scale/writeScale.sh* et *compute_scale/clean.sh*) permettent de faire fonctionner le projet facilement.
### writeScale.sh
Ce script prend en entrée un répertoire contenant des images et le nom du fichier résultat. Il écrit l'échelle de conversion de pixel à cm dans le fichier résultat sous la forme : "nom de l'image | nom de pixel le long du côté du carré du damier". Échelle est le nombre de pixel le long d'un côté du damier.
```
./writeScale.sh <Path to your images>  <name of output file>
```
### clean.sh
Ce script ne prend aucune entrée. Il permet de nettoyer les fichiers temporaires générés lors de l'appel du script *writeScale.sh*. Il faut l'exécuter après chaque appel de *writeScale.sh*.
```
./clean.sh
```
# Mesure sur les images via ImageJ
Nous avons développé un plugin ImageJ (*compute_scale/segment_mesure.java*) pour changer l'échelle du logiciel ImageJ. Cela permet de faire des mesures en cm (comme le diamètre ou la surface) directement depuis le logiciel ImageJ. Pour utiliser ce plugin, il faut l'installer via le menu *plugin/install/*. Une fois lancé, le plugin demande de sélectionner le fichier contenant les échelles de conversion (généré par *writeScale.sh*), puis une fenêtre de log s'ouvre. Tant que cette fenêtre de log est ouverte vous pouvez ouvrir les images et faire vos mesures dessus.
