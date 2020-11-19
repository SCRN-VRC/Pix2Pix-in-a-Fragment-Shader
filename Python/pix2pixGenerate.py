# example of loading a pix2pix model and using it for one-off image translation
from keras.models import load_model
from keras.preprocessing.image import img_to_array
from keras.preprocessing.image import array_to_img
from keras.preprocessing.image import load_img
from keras.preprocessing.image import save_img
from keras import backend as K
from numpy import load
from numpy import expand_dims
from numpy import zeros
from matplotlib import pyplot

def test():
    a = zeros((256, 256, 3))
    for k in range(0, 3):
        for i in range(0, 256):
            for j in range(0, 256):
                if k == 0:
                    a[i][j][k] = (i / 255.0) * (j / 255.0) * 2.0 - 1.0
                elif k == 1:
                    a[i][j][k] = ((255.0 - i) / 255.0) * (j / 255.0) * 2.0 - 1.0
                else:
                    a[i][j][k] = (i / 255.0) * ((255.0 - j) / 255.0) * 2.0 - 1.0
    a = expand_dims(a, 0)
    return a

# load an image
def load_image(filename, size=(256,256)):
	# load image with the preferred size
	pixels = load_img(filename, target_size=size)
	# convert to numpy array
	pixels = img_to_array(pixels)
	# scale from [0,255] to [-1,1]
	pixels = (pixels - 127.5) / 127.5
	# reshape to 1 sample
	pixels = expand_dims(pixels, 0)
	return pixels

# load source image
src_image = load_image('input4.jpg')
#src_image = test()
print('Loaded', src_image.shape)
# load model
model = load_model('model_074400.h5')

weights = model.get_weights()

# for i in range(0, len(weights)):
#     print(str(i) + ' ' + str(weights[i].shape))

# generate image from source
gen_image = model.predict(src_image)
# scale from [-1,1] to [0,1]
gen_image = (gen_image + 1) / 2.0
gen_image = array_to_img(gen_image[0])
#save_img('output3.jpg', gen_image)
pyplot.imshow(gen_image)

outputs = [K.function([model.input], [layer.output])([src_image, 1]) for layer in model.layers]