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

load_name 	= model.name 
filter_dir 	= os.path.join(os.getcwd(), 'model', 'filters')
net			= model.unet()
net.load_weights(model.fullname)


layers = ["conv2d_{}".format(i) for i in range(1, 16, 2)]

#layer = net.get_layer(name="conv2d_1")

for j, name in enumerate(layers):
	layer = net.get_layer(name=name)
	weights = layer.get_weights()[0]
	w, h, c, n = weights.shape
	subfilter = "".join([filter_dir, "/{}".format(j)])
	if not os.path.isdir(subfilter):
		os.makedirs(subfilter)
	print w, h, c, n
	for i in range(n):
		fi = weights[:,:,:,i]
		#ri = weights[:,:,0,i]
		#gi = weights[:,:,1,i]
		#bi = weights[:,:,2,i]
		#scipy.misc.toimage(ri, cmin=-1.0, cmax=1.0).save('{}/r{}.jpg'.format(subfilter, i))
		#scipy.misc.toimage(gi, cmin=-1.0, cmax=1.0).save('{}/b{}.jpg'.format(subfilter, i))
		scipy.misc.toimage(fi, cmin=-1.0, cmax=1.0).save('{}/g{}.jpg'.format(subfilter, i))
		#scipy.misc.toimage(bi, cmin=-1.0, cmax=1.0).save('{}/g{}.jpg'.format(subfilter, i))		
