# stage_Tai
## Segmentation de grume de bois
### Par CNN
#### Dépendences
- Python
- Keras
- TensorFlow
- OpenCV
- Scikit-image
#### Test de la prédiction du deepLearning ( besoin du repertoire contenant les véritées terrain)

1. Placer les images à segmenter dans le repertoire /deeplearning/dataset/test/input
attention, les images doivent être de la même dimension que les celles qui ont été utilisé pour entrainer le modèle(pour l'instant 256 par 256).
Le script resize.py permet de redimensionner les images d'un repertoire dans une taille préçisé.
```
python3 resize.py <path/to/repository> <newsize>
```
2. Procéder à la prédiction.
- activer l'environnement virtuel (si vous en pocédez un)
```
source ./venv/bin/activate
```
- lancer la prédiction 
```
python3 predict.py
```
3. {optionnel} Créer des images pour visualiser le résultat de la prédiction (superposition de l'image segmenté avec l'image de base).
- a la racine du projet créer un repertoire comme suit :
```
mkdir /test/masqued_image
```
- executer le script comparator.py comme suit :
```
python3 comparator.py ../deeplearning/dataset/test/input/ ../deeplearning/dataset/test/output/ masqued_image/
```
Ce script recupère les images d'entrée du CNN et images de sortie (les images segmentées). Il les additionne et sauvegarde le rasultats dans le repertoire 'masqued_image'

4. Calculer l'erreur de segmentation (par rapport à la véritée terrain).
l'erreur est mesurée entre l'image attendu (celle de la véritée terrain) et l'image en sortie du CNN. Elle est calculée en faisant un XOR entre la sortie du CNN et l'image attendu. Le nombre de pixel différent de zéro résultant du XOR est ensuite divisé par le nombre de pixels différents de zéro dans l'image attendue.
Il y a deux manières d'executer le script erreur_grume.py :
- Pour la version normal :
```
-erreur_grume.py 
```
- Pour la version visuel :
```
-erreur_grume.py v
```
