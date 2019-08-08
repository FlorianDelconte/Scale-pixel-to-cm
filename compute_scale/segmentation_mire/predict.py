import numpy as np
import os
import csv
import sys
import skimage.io as io
import cv2
#import skimage.transform as transform
#import skimage.transform as trans

#import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as img
import scipy.misc

#from sklearn.model_selection import train_test_split

from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint, LearningRateScheduler
from tensorflow.keras import backend as keras

import model
import cv2

net = model.unet()
net.load_weights(model.fullname)

if len(sys.argv) == 3:
	dir_input= sys.argv[1]
	dir_output=sys.argv[2]
else:
	dir_input 	= model.test_dir_input
	dir_output 	= model.test_dir_output


#for i in range(20):
for path in os.listdir(dir_input):
	if path == ".DS_Store": continue
	file 	= "{}/{}".format(dir_input, path)

	img 	= io.imread(file, plugin='matplotlib')


	h=img.shape[0]
	w=img.shape[1]

	print(img.shape)
	img 	= cv2.resize(img, (model.height, model.width), interpolation =cv2.INTER_AREA)
	img 	= np.array([img])
	img 	= np.reshape(img, [1, model.height, model.width, model.channels])	
	px 		= net.predict(img, verbose=1)
	#resize de la sortie a la taille de l'image de base
	segmentation=	px[0,:,:,0]
	segmentation	= scipy.misc.imresize(segmentation, (h,w), interp='nearest')
	segmentation	= scipy.misc.toimage(segmentation, cmin=0.0, cmax=1.0)
	#segmentation 	= cv2.resize(segmentation, (h, w), interpolation =cv2.INTER_NEAREST)

	segmentation.save('{}/{}'.format(dir_output, path))
