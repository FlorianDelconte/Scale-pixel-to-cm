import numpy as np
import os
import csv
import sys
import skimage.io as io
import skimage.transform as transform
#import skimage.transform as trans

#import matplotlib.pyplot as plt
import numpy as np
import matplotlib.image as img
import scipy.misc

from sklearn.model_selection import train_test_split

from keras.models import *
from keras.layers import *
from keras.optimizers import *
from keras.callbacks import ModelCheckpoint, LearningRateScheduler
from keras import backend as keras

import model
import cv2

net = model.unet()
net.load_weights(model.fullname)


if len(sys.argv) > 2:
	dir_input 	= os.path.join(os.getcwd(), 'dataset', sys.argv[1], 'input')
	dir_output 	= os.path.join(os.getcwd(), 'dataset', sys.argv[1], 'output')
	print (dir_input)
else:
	dir_input 	= model.test_dir_input
	dir_output 	= model.test_dir_output

#directory = model.test_dir_input
#for i in range(20):
for path in os.listdir(dir_input):
	if path == ".DS_Store": continue
	file 	= "{}/{}".format(dir_input, path)
	img 	= io.imread(file, plugin='matplotlib')
	img 	= np.array([img])	
	print(img.shape)
	img 	= np.reshape(img, [1, model.height, model.width, model.channels])
	px 		= net.predict(img, verbose=1)
	scipy.misc.toimage(px[0,:,:,0], cmin=0.0, cmax=1.0).save('{}/{}'.format(dir_output, path))
