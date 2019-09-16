import numpy as np
import os
#import skimage.io as io
#import skimage.transform as trans
import numpy as np

from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint, LearningRateScheduler
from tensorflow.keras import backend as keras

import tensorflow as tf

import os
#####################
# Global Parameters #
# ----------------- #
#####################
height		= 400
width   	= 400
channels 	= 3
numFilt 	= 16
batch_size		= 3
epochs			= 10
steps_per_epoch 	= 100
validation_steps	= 10
numDatas = 54
object = "mire"
imgFormat = "PNG"
size_folder="normale"

#name = "LEN_"+s ize_folder+"_"+object+"_c.hdf5"
name= "400_M_16.hdf5"


train_folder	= "train"
valid_folder	= "valid"
test_folder		= "test"


train_dir_input 	= os.path.join(os.getcwd(), '..','..','DATA',imgFormat, train_folder, object,size_folder, 'input')
valid_dir_input 	= os.path.join(os.getcwd(), '..','..','DATA',imgFormat, valid_folder, object,size_folder, 'input')
test_dir_input 		= os.path.join(os.getcwd(), '..','..','DATA',imgFormat, test_folder, object,size_folder, 'input')

train_dir_output 	= os.path.join(os.getcwd(), '..','..','DATA',imgFormat ,train_folder, object, size_folder, 'output')
valid_dir_output	= os.path.join(os.getcwd(), '..','..','DATA',imgFormat, valid_folder, object, size_folder, 'output')
test_dir_output 	= os.path.join(os.getcwd(), '..','..','DATA',imgFormat, test_folder, object,size_folder, 'output')

save_dir 			= os.path.join(os.getcwd(),'model', 'save')

fullname 			= "".join([save_dir, '/', name])

#########
# Model #
# ----- #
#########
def unet(pretrained_weights = None,input_size = (height, width, channels)):
	## U-net

	# inputs = Input(input_size)
	# conv1 = Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
	# drop1 = Dropout(0.1)(conv1)
	# conv1 = Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(drop1)
	# #pool1 = MaxPooling2D(pool_size=(2, 2))(drop1)

	# pool1 = MaxPooling2D(pool_size=(2, 2))(conv1)
	# conv2 = Conv2D(2*numFilt, 5, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool1)
	# drop2 = Dropout(0.1)(conv2)
	# conv2 = Conv2D(2*numFilt, 5, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(drop2)

	# pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)
	# conv3 = Conv2D(4*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool2)
	# drop3 = Dropout(0.5)(conv3)
	# conv3 = Conv2D(4*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(drop3)
	# up3   = UpSampling2D(size=(2, 2))(conv3)
	# #pool3 = MaxPooling2D(pool_size=(2, 2))(drop3)

	# # conv4 = Conv2D(8*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool3)
	# # conv4 = Conv2D(8*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv4)
	# # drop4 = Dropout(0.5)(conv4)
	# # pool4 = MaxPooling2D(pool_size=(2, 2))(drop4)

	# # conv5 = Conv2D(16*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool4)
	# # conv5 = Conv2D(16*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv5)
	# # drop5 = Dropout(0.5)(conv5)

	# #up6 = Conv2D(8*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(drop5))
	# merge4 = concatenate([up3, conv2], axis = 3)
	# conv4 = Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge4)
	# drop4 = Dropout(0.1)(conv4)
	# conv4 = Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(drop4)
	# up4	  = UpSampling2D(size = (2,2))(conv4)

	# merge5 = concatenate([up4, conv1], axis = 3)
	# conv5 = Conv2D(numFilt, 5, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge5)
	# drop5 = Dropout(0.1)(conv5)
	# conv5 = Conv2D(numFilt, 5, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(drop5)

	# conv6 = Conv2D(2, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv5)

	# conv10 = Conv2D(1, 1, activation = 'sigmoid')(conv6)


	#up8 = Conv2D(2*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv7))
	#up8 = Conv2D(2*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(drop3))
	#merge8 = concatenate([conv2,up8], axis = 3)
	#merge8 = concatenate([drop2,up8], axis = 3)
	#conv8 = Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge8)
	#conv8 = Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv8)

	#up9 = Conv2D(numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv8))
	#merge9 = concatenate([conv1,up9], axis = 3)
	##conv9 = Conv2D(numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge9)
	#conv9 = Conv2D(numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv9)
	#conv9 = Conv2D(2, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv9)
	#conv10 = Conv2D(1, 1, activation = 'sigmoid')(conv9)

	## Local then Global Path
	# conv1 = Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
	# conv1 = Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv1)
	# drop1 = Dropout(0.5)(conv1)
	# pool1 = MaxPooling2D(pool_size=(2, 2))(drop1)

	# conv2 = Conv2D(2*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool1)
	# conv2 = Conv2D(2*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv2)
	# drop2 = Dropout(0.5)(conv2)
	# pool2 = MaxPooling2D(pool_size=(2, 2))(drop2)

	# gconv = Conv2D(numFilt, 17, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
	# gconv = Conv2D(numFilt, 17, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(gconv)
	# gdrop = Dropout(0.5)(gconv)
	# gpool = MaxPooling2D(pool_size=(2, 2))(gdrop)

	# up1   = Conv2D(numFilt, 1, activation = 'sigmoid')(UpSampling2D(size = (2,2))(pool2))
	# up2   = Conv2D(numFilt, 1, activation = 'sigmoid')(UpSampling2D(size = (2,2))(up1))
	# gup   = Conv2D(numFilt, 1, activation = 'sigmoid')(UpSampling2D(size = (2,2))(gpool))
	# merge = concatenate([up2, gup], axis = 3)
	# conv10 = Conv2D(1, 1, activation = 'sigmoid')(merge)

	## Global and Local Path
	# inputs 	= Input(input_size)
	# lc1 	= Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
	# ld1		= Dropout(0.1)(lc1)
	# lc1		= Conv2D(numFilt, 7, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(ld1)
	# lpool1 	= MaxPooling2D(pool_size=(2, 2))(lc1)

	# lc2 	= Conv2D(2*numFilt, 5, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(lpool1)
	# ld2		= Dropout(0.1)(lc2)
	# lc2		= Conv2D(2*numFilt, 5, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(ld2)
	# lpool2 	= MaxPooling2D(pool_size=(2, 2))(lc2)

	# lc3 	= Conv2D(4*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(lpool2)
	# ld3		= Dropout(0.1)(lc3)
	# lc3		= Conv2D(4*numFilt, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(ld3)
	# ld3		= Dropout(0.5)(lc3)

	# up6 	= Conv2D(2*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(ld3))
	# merge6 	= concatenate([lc2, up6], axis = 3)
	# conv6 	= Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge6)
	# conv6 	= Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv6)

	# up7 	= Conv2D(numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv6))
	# merge7 	= concatenate([lc1,up7], axis = 3)
	# lup 	= Conv2D(numFilt, 1, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge7)

	# gc1		= Conv2D(numFilt, 29, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
	# gd1		= Dropout(0.1)(gc1)
	# gc1		= Conv2D(numFilt, 29, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(gd1)
	# gpool1	= MaxPooling2D(pool_size=(2, 2))(gc1)
	# gup		= Conv2D(numFilt, 1, activation = 'sigmoid')(UpSampling2D(size = (2,2))(gpool1))

	# merge = concatenate([lup, gup], axis = 3)

	# conv10 = Conv2D(1, 1, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge)

	inputs = Input(input_size)
	conv1 = Conv2D(numFilt, 11, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)#11
	conv1 = Conv2D(numFilt, 11, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv1)#11
	pool1 = MaxPooling2D(pool_size=(2, 2))(conv1)
	conv2 = Conv2D(2*numFilt, 9, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool1)#9
	conv2 = Conv2D(2*numFilt, 9, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv2)#9
	pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)
	conv3 = Conv2D(4*numFilt, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool2)#7
	conv3 = Conv2D(4*numFilt, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv3)#7
	pool3 = MaxPooling2D(pool_size=(2, 2))(conv3)
	conv4 = Conv2D(8*numFilt, 5, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool3)#5
	conv4 = Conv2D(8*numFilt, 5, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv4)#5
	drop4 = Dropout(0.5)(conv4)
	pool4 = MaxPooling2D(pool_size=(2, 2))(drop4)

	conv5 = Conv2D(16*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool4)
	conv5 = Conv2D(16*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv5)
	drop5 = Dropout(0.5)(conv5)

	up6 	= Conv2D(8*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(drop5))
	merge6	= concatenate([drop4,up6], axis = 3)
	conv6	= Conv2D(8*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge6)
	conv6	= Conv2D(8*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv6)

	up7		= Conv2D(4*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv6))
	merge7	= concatenate([conv3,up7], axis = 3)
	conv7	= Conv2D(4*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge7)
	conv7	= Conv2D(4*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv7)

	up8		= Conv2D(2*numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv7))
	merge8	= concatenate([conv2,up8], axis = 3)
	conv8	= Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge8)
	conv8	= Conv2D(2*numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv8)

	up9 = Conv2D(numFilt, 2, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(UpSampling2D(size = (2,2))(conv8))
	merge9 = concatenate([conv1,up9], axis = 3)
	conv9 = Conv2D(numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge9)
	conv9 = Conv2D(numFilt, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv9)
	conv9 = Conv2D(2, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(conv9)
	conv10 = Conv2D(1, 1, activation = 'sigmoid')(conv9)

	#conv11 = Conv2D(1, 1, activation = 'relu')(conv9)
	#merge10  = concatenate([inputs, conv11], axis = 3)
	#conv10	= Conv2D(1, 3, data_format='channels_last', activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge10)

	model = Model(inputs = inputs, outputs = conv10)
	#binary_crossentropy
	model.compile(optimizer = Adam(lr = 1e-4), loss = 'binary_crossentropy', metrics = ['accuracy'])

	return model
