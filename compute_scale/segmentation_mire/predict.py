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
from PIL import Image

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
	if file=="/home/doozkawa/Bureau/stage_Tai/compute_scale/segmentation_mire/../../DATA/PNG/test/mire/512_512/input/huawei_E074B_5.png" :
		print(file)
		img 	= io.imread(file, plugin='matplotlib')


		h=img.shape[0]
		w=img.shape[1]

		print(img.shape)
		img 	= cv2.resize(img, (model.height, model.width), interpolation =cv2.INTER_AREA)
		img 	= np.array([img])
		img 	= np.reshape(img, [1, model.height, model.width, model.channels])
		px 		= net.predict(img, verbose=1)
		#resize de la sortie a la taille de l'image de base
		segmentation	= px[0,:,:,0]
		segmentation 	= cv2.resize(segmentation, (h, w), interpolation =cv2.INTER_NEAREST)
		segmentation = (segmentation * 255).astype(np.uint8)
		segmentation	=Image.fromarray(segmentation,"L")
		segmentation.save('{}/{}'.format(dir_output, path))
