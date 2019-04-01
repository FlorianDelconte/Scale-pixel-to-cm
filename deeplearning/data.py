from keras.preprocessing.image import ImageDataGenerator
import numpy as np
import os
import glob
import skimage.io as io
import skimage.transform as trans
import itertools
import image

import model

def trainset_generator(batch_size,
                       train_path,
                       image_folder,
                       mask_folder,
                       aug_dict,
                       image_color_mode = "rgb",
                       mask_color_mode  = "grayscale",
                       image_save_prefix= "image",
                       mask_save_prefix = "mask",
                       flag_multi_class = False,
                       num_class = 2,
                       save_to_dir = "visu_data_gen/",
                       target_size = (model.height, model.width),
                       seed = 1):
    '''
        can generate image and mask at the same time
        use the same seed for image_datagen and mask_datagen to ensure the transformation for image and mask is the same
        if you want to visualize the results of generator, set save_to_dir = "your path"
        '''
    image_datagen   = ImageDataGenerator(**aug_dict)
    mask_datagen    = ImageDataGenerator(**aug_dict)
    valid_datagen   = ImageDataGenerator(**aug_dict)

    image_generator = image_datagen.flow_from_directory(
                                                    train_path,
                                                    classes = [image_folder],
                                                    class_mode = 'categorical',
                                                    target_size = target_size,
                                                    color_mode=image_color_mode,
                                                    batch_size = batch_size,
                                                    save_to_dir = save_to_dir,
                                                    save_prefix  = image_save_prefix,
                                                    seed = seed)
    mask_generator = mask_datagen.flow_from_directory(
                                                  train_path,
                                                  classes = [mask_folder],
                                                  class_mode = 'categorical',
                                                  target_size = target_size,
                                                  color_mode = mask_color_mode,
                                                  batch_size = batch_size,
                                                  save_to_dir = save_to_dir,
                                                  save_prefix  = mask_save_prefix,
                                                  seed = seed)

    while True:
        x = image_generator.next()
        y = mask_generator.next()
        yield (x[0], y[0])



def gen_train_npy(image_path,mask_path,flag_multi_class = False,num_class = 2,image_prefix = "image",mask_prefix = "mask",image_as_gray = True,mask_as_gray = True):
    image_name_arr = glob.glob(os.path.join(image_path,"%s*.png"%image_prefix))
    image_arr = []
    mask_arr = []
    for index,item in enumerate(image_name_arr):
        img = io.imread(item,as_gray = image_as_gray)
        img = np.reshape(img,img.shape + (1,)) if image_as_gray else img
        mask = io.imread(item.replace(image_path,mask_path).replace(image_prefix,mask_prefix),as_gray = mask_as_gray)
        mask = np.reshape(mask,mask.shape + (1,)) if mask_as_gray else mask
        #img,mask = adjustData(img,mask,flag_multi_class,num_class)
        image_arr.append(img)
        mask_arr.append(mask)
    image_arr = np.array(image_arr)
    mask_arr = np.array(mask_arr)
    return image_arr,mask_arr


#=====================#
#   Generate datas    #
#=====================#

'''train_dir = os.path.join(os.getcwd(), 'dataset', 'train')
input_folder    = 'input'
label_folder    = 'output'
save_dir        = 'visu_data_gen'
aug_dir         = "".join([train_dir, '/', save_dir])


#transform param
data_gen_args = dict(rotation_range=0.5,
                     width_shift_range=0.2,
                     height_shift_range=0.2,
                     shear_range=0.2,
                     zoom_range=0.2,
                     horizontal_flip=True,
                     fill_mode='wrap')

data_gen_args = dict(rotation_range=0.2,
                     width_shift_range=0.05,
                     height_shift_range=0.05,
                     shear_range=0.05,
                     zoom_range=0.1,
                     horizontal_flip=True,
                     fill_mode='nearest')
#number of méta image you want to create.
number_batch = 10
__generator = trainset_generator(number_batch, train_dir, input_folder, label_folder,
                                      data_gen_args, save_to_dir=aug_dir)


for i,batch in enumerate(__generator):
    print(i)
    if(i >= number_batch):
        break'''


#image_arr, mask_arr = gen_train_npy(aug_dir, aug_dir)
