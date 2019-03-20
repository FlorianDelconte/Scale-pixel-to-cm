import numpy as np 
import os
#os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
import csv
import skimage.io as io
import skimage.transform as transform
#import skimage.transform as trans
import numpy as np
import matplotlib.image as img

from sklearn.model_selection import train_test_split

from keras.models import *
from keras.layers import *
from keras.optimizers import *
from keras.callbacks import ModelCheckpoint, LearningRateScheduler
from keras import backend as keras
from keras.utils import to_categorical

import model
import data

# Parameters Input
numChannels = model.channels
height  = model.height
width   = model.width
batch_size = model.batch_size
epochs = model.epochs

# Folders Train, Valid, Test and Save
train_dir = os.path.join(os.getcwd(), 'dataset', model.train_folder)
valid_dir = os.path.join(os.getcwd(), 'dataset', model.valid_folder)
input_folder    = 'input'
label_folder    = 'output'


data_gen_args = dict(rescale = 1.0 / 255,
                     rotation_range=0.2,
                     width_shift_range=0.05,
                     height_shift_range=0.05,
                     shear_range=0.05,
                     zoom_range=0.05,
                     horizontal_flip=True,
                     fill_mode='nearest')


def loadDataset(directory, h=model.height, w=model.width, c=model.channels, n=model.numDatas):
    #datas = np.zeros((h, w, c, n))
    
    if os.path.isdir(directory):
        mylist = os.listdir(directory)
        if '.DS_Store' in mylist: mylist.remove('.DS_Store')
        
        mylist = ["{}/{}".format(directory, file) for file in mylist]
        imgs = io.imread_collection(mylist, plugin='matplotlib')
        imgs = np.array([img for img in imgs])
        
        return imgs

#        for (i, file) in enumerate(os.listdir(directory)):
#           if file=='.DS_Store': continue
#           
#           fullpath = "{}/{}".format(directory, file)
#           #print fullpath
#           if os.path.isdir(fullpath): continue
#
#           image = io.imread(fullpath, plugin='matplotlib')
#           #image = io.imread_collection(os.listdir(directory))
#           #image = transform.rescale(image, (h, w), mode='reflect', anti_aliasing=True, multichannel=True)
#           #print image[1]
#
#           datas[:, :, :, i-1] = image

#    return datas

def loadTargets(directory, h=model.height, w=model.width, c=model.channels, n=model.numDatas):
    #targets = np.zeros((n, 2))
    if os.path.isdir(target_dir):
        
        mylist = os.listdir(directory)
        if '.DS_Store' in mylist: mylist.remove('.DS_Store')
        
        mylist = ["{}/{}".format(directory, file) for file in mylist]
        
        # IF CSV
        #for (i, file) in enumerate(mylist):
        #    with open(file, 'r') as text:
        #        line = csv.reader(text, delimiter=',')
        #        for row in line:
        #            targets[i, :] = np.array(row, dtype=np.int32)
        
        # IF JPG
        trgs = io.imread_collection(mylist, plugin='matplotlib')
        trgs = np.array([t for t in trgs])
        return trgs

# Create network
__generators    = data.trainset_generator(model.batch_size, train_dir, input_folder, label_folder,
                                 data_gen_args, save_to_dir=None)

__validator     = data.trainset_generator(1, valid_dir, input_folder, label_folder,
                                          data_gen_args, save_to_dir=None)

model_checkpoint = ModelCheckpoint(model.fullname,
                                   monitor='val_loss',
                                   verbose=1,
                                   save_best_only=True)
net = model.unet()
net.summary()
try:
  net.load_weights(model.fullname)
except IOError:
  pass
net.fit_generator(__generators,
                  steps_per_epoch   = model.steps_per_epoch,
                  validation_data   = __validator,
                  validation_steps  = model.validation_steps,
                  epochs=model.epochs,
                  callbacks=[model_checkpoint])

#if not os.path.isdir(save_dir):
#    os.makedirs(save_dir)
#model_path = os.path.join(save_dir, model_name)
#net.save(model_path)

# Training network
#for i in range(1, model.epochs+1):
#    print("Epochs number : {}".format(i))
#    subx = []
#    suby = []
#    #for (j, _) in enumerate(trains):
#    #        xs = np.random.randint(540-512)
#    #    ys = np.random.randint(720-512)
#    #    samplex = trains[j, xs:xs+512, ys:ys+512, :]
#    #    sampley = targets[j, xs:xs+512, ys:ys+512]
#    #    subx.append(samplex)
#    #        suby.append(sampley)
#
#    #    subx = np.array(subx)
#    #suby = np.array(suby)
#
#    for (j, _) in enumerate(trains):
#        samplex = trains[j, :, :]
#        sampley = targets[j, :, :]
#        sampley = sampley.astype(np.bool)
#        sampley = sampley.astype(np.float32)
#        #sampley = sampley.astype(np.int8)
#
#        subx.append(samplex)
#        suby.append(sampley)
#
#    subx = np.array(subx)
#    suby = np.array(suby)
#
#    x_train, x_test, y_train, y_test = train_test_split(subx, suby, test_size=0.3)
#
#    x_train = np.reshape(x_train, [34, 512, 512, 1])
#    x_test  = np.reshape(x_test, [15, 512, 512, 1])
#
#    y_train = np.reshape(y_train, [34, 512, 512, 1])
##y_train = to_categorical(y_train)
##   print y_train[1,:,:,1]
#
#    y_test  = np.reshape(y_test, [15, 512, 512, 1])
#    #y_test = to_categorical(y_test, num_classes=1)
#
#    print("Start training")
#    net.fit(x_train, y_train,
#            verbose=1,
#            batch_size=model.batch_size,
#            epochs=1,
#            validation_data=(x_test, y_test),
#            shuffle=True)
#
#    # Save model and weights
#    if not os.path.isdir(save_dir):
#        os.makedirs(save_dir)
#    model_path = os.path.join(save_dir, model_name)
#    net.save(model_path)
#
#print('Saved trained model at %s ' % model_path)
## Score trained model.
#scores = net.evaluate(x_test, y_test, verbose=1)
#print('Test loss:', scores[0])
#print('Test accuracy:', scores[1])


