/*

	This code VERY SLOW, it only serves as a draft to make sure I'm
	doing the math correctly before implementing it in HLSL

	- SCRN
__________________________________________________________________________________________________
Layer (type)                    Output Shape         Param #     Connected to
==================================================================================================
 0 input_15 (InputLayer)           [(None, 256, 256, 3) 0
__________________________________________________________________________________________________
 1 conv2d_56 (Conv2D)              (None, 128, 128, 64) 3136        input_15[0][0]
__________________________________________________________________________________________________
 2 leaky_re_lu_35 (LeakyReLU)      (None, 128, 128, 64) 0           conv2d_56[0][0] 1
__________________________________________________________________________________________________
 3 conv2d_57 (Conv2D)              (None, 64, 64, 64)   65600       leaky_re_lu_35[0][0]
__________________________________________________________________________________________________
 4 leaky_re_lu_36 (LeakyReLU)      (None, 64, 64, 64)   0           conv2d_57[0][0] 2
__________________________________________________________________________________________________
 5 batch_normalization_42 (BatchNo (None, 64, 64, 64)   256         leaky_re_lu_36[0][0]
__________________________________________________________________________________________________
 6 conv2d_58 (Conv2D)              (None, 32, 32, 128)  131200      batch_normalization_42[0][0]
__________________________________________________________________________________________________
 7 leaky_re_lu_37 (LeakyReLU)      (None, 32, 32, 128)  0           conv2d_58[0][0] 3
__________________________________________________________________________________________________
 8 batch_normalization_43 (BatchNo (None, 32, 32, 128)  512         leaky_re_lu_37[0][0]
__________________________________________________________________________________________________
 9 conv2d_59 (Conv2D)              (None, 16, 16, 256)  524544      batch_normalization_43[0][0]
__________________________________________________________________________________________________
10 leaky_re_lu_38 (LeakyReLU)      (None, 16, 16, 256)  0           conv2d_59[0][0] 4
__________________________________________________________________________________________________
11 batch_normalization_44 (BatchNo (None, 16, 16, 256)  1024        leaky_re_lu_38[0][0]
__________________________________________________________________________________________________
12 conv2d_60 (Conv2D)              (None, 8, 8, 256)    1048832     batch_normalization_44[0][0]
__________________________________________________________________________________________________
13 leaky_re_lu_39 (LeakyReLU)      (None, 8, 8, 256)    0           conv2d_60[0][0] 5
__________________________________________________________________________________________________
14 batch_normalization_45 (BatchNo (None, 8, 8, 256)    1024        leaky_re_lu_39[0][0]
__________________________________________________________________________________________________
15 conv2d_61 (Conv2D)              (None, 4, 4, 256)    1048832     batch_normalization_45[0][0]
__________________________________________________________________________________________________
16 leaky_re_lu_40 (LeakyReLU)      (None, 4, 4, 256)    0           conv2d_61[0][0] 6
__________________________________________________________________________________________________
17 batch_normalization_46 (BatchNo (None, 4, 4, 256)    1024        leaky_re_lu_40[0][0]
__________________________________________________________________________________________________
18 conv2d_62 (Conv2D)              (None, 2, 2, 512)    2097664     batch_normalization_46[0][0]
__________________________________________________________________________________________________
19 leaky_re_lu_41 (LeakyReLU)      (None, 2, 2, 512)    0           conv2d_62[0][0] 7
__________________________________________________________________________________________________
20 batch_normalization_47 (BatchNo (None, 2, 2, 512)    2048        leaky_re_lu_41[0][0]
__________________________________________________________________________________________________
21 up_sampling2d_17 (UpSampling2D) (None, 4, 4, 512)    0           batch_normalization_47[0][0]
__________________________________________________________________________________________________
22 conv2d_63 (Conv2D)              (None, 4, 4, 512)    4194816     up_sampling2d_17[0][0]
__________________________________________________________________________________________________
23 batch_normalization_48 (BatchNo (None, 4, 4, 512)    2048        conv2d_63[0][0] 8
__________________________________________________________________________________________________
24 concatenate_18 (Concatenate)    (None, 4, 4, 768)    0           batch_normalization_48[0][0]
																 batch_normalization_46[0][0]
__________________________________________________________________________________________________
25 up_sampling2d_18 (UpSampling2D) (None, 8, 8, 768)    0           concatenate_18[0][0]
__________________________________________________________________________________________________
26 conv2d_64 (Conv2D)              (None, 8, 8, 256)    3145984     up_sampling2d_18[0][0]
__________________________________________________________________________________________________
27 batch_normalization_49 (BatchNo (None, 8, 8, 256)    1024        conv2d_64[0][0] 9
__________________________________________________________________________________________________
28 concatenate_19 (Concatenate)    (None, 8, 8, 512)    0           batch_normalization_49[0][0]
																 batch_normalization_45[0][0]
__________________________________________________________________________________________________
29 up_sampling2d_19 (UpSampling2D) (None, 16, 16, 512)  0           concatenate_19[0][0]
__________________________________________________________________________________________________
30 conv2d_65 (Conv2D)              (None, 16, 16, 256)  2097408     up_sampling2d_19[0][0]
__________________________________________________________________________________________________
31 batch_normalization_50 (BatchNo (None, 16, 16, 256)  1024        conv2d_65[0][0] 10
__________________________________________________________________________________________________
32 concatenate_20 (Concatenate)    (None, 16, 16, 512)  0           batch_normalization_50[0][0]
																 batch_normalization_44[0][0]
__________________________________________________________________________________________________
33 up_sampling2d_20 (UpSampling2D) (None, 32, 32, 512)  0           concatenate_20[0][0]
__________________________________________________________________________________________________
34 conv2d_66 (Conv2D)              (None, 32, 32, 128)  1048704     up_sampling2d_20[0][0]
__________________________________________________________________________________________________
35 batch_normalization_51 (BatchNo (None, 32, 32, 128)  512         conv2d_66[0][0] 11
__________________________________________________________________________________________________
36 concatenate_21 (Concatenate)    (None, 32, 32, 256)  0           batch_normalization_51[0][0]
																 batch_normalization_43[0][0]
__________________________________________________________________________________________________
37 up_sampling2d_21 (UpSampling2D) (None, 64, 64, 256)  0           concatenate_21[0][0]
__________________________________________________________________________________________________
38 conv2d_67 (Conv2D)              (None, 64, 64, 64)   262208      up_sampling2d_21[0][0]
__________________________________________________________________________________________________
39 batch_normalization_52 (BatchNo (None, 64, 64, 64)   256         conv2d_67[0][0] 12
__________________________________________________________________________________________________
40 concatenate_22 (Concatenate)    (None, 64, 64, 128)  0           batch_normalization_52[0][0]
																 batch_normalization_42[0][0]
__________________________________________________________________________________________________
41 up_sampling2d_22 (UpSampling2D) (None, 128, 128, 128 0           concatenate_22[0][0]
__________________________________________________________________________________________________
42 conv2d_68 (Conv2D)              (None, 128, 128, 64) 131136      up_sampling2d_22[0][0]
__________________________________________________________________________________________________
43 batch_normalization_53 (BatchNo (None, 128, 128, 64) 256         conv2d_68[0][0] 13
__________________________________________________________________________________________________
44 concatenate_23 (Concatenate)    (None, 128, 128, 128 0           batch_normalization_53[0][0]
																 leaky_re_lu_35[0][0]
__________________________________________________________________________________________________
45 up_sampling2d_23 (UpSampling2D) (None, 256, 256, 128 0           concatenate_23[0][0]
__________________________________________________________________________________________________
46 conv2d_69 (Conv2D)              (None, 256, 256, 3)  6147        up_sampling2d_23[0][0]
__________________________________________________________________________________________________
47 activation_7 (Activation)       (None, 256, 256, 3)  0           conv2d_69[0][0] 14
==================================================================================================
Total params: 15,817,219
Trainable params: 15,811,715
Non-trainable params: 5,504
__________________________________________________________________________________________________
	Weights

	 L1
	 0 (4, 4, 3, 64)
	 1 (64,)
	 L2
	 2 (4, 4, 64, 64)
	 3 (64,)
	 4 (64,)
	 5 (64,)
	 6 (64,)
	 7 (64,)
	 L3
	 8 (4, 4, 64, 128)
	 9 (128,)
	10 (128,)
	11 (128,)
	12 (128,)
	13 (128,)
	L4
	14 (4, 4, 128, 256)
	15 (256,)
	16 (256,)
	17 (256,)
	18 (256,)
	19 (256,)
	L5
	20 (4, 4, 256, 256)
	21 (256,)
	22 (256,)
	23 (256,)
	24 (256,)
	25 (256,)
	L6
	26 (4, 4, 256, 256)
	27 (256,)
	28 (256,)
	29 (256,)
	30 (256,)
	31 (256,)
	L7
	32 (4, 4, 256, 512)
	33 (512,)
	34 (512,)
	35 (512,)
	36 (512,)
	37 (512,)
	L8
	38 (4, 4, 512, 512)
	39 (512,)
	40 (512,)
	41 (512,)
	42 (512,)
	43 (512,)
	L9
	44 (4, 4, 768, 256)
	45 (256,)
	46 (256,)
	47 (256,)
	48 (256,)
	49 (256,)
	L10
	50 (4, 4, 512, 256)
	51 (256,)
	52 (256,)
	53 (256,)
	54 (256,)
	55 (256,)
	L11
	56 (4, 4, 512, 128)
	57 (128,)
	58 (128,)
	59 (128,)
	60 (128,)
	61 (128,)
	L12
	62 (4, 4, 256, 64)
	63 (64,)
	64 (64,)
	65 (64,)
	66 (64,)
	67 (64,)
	L13
	68 (4, 4, 128, 64)
	69 (64,)
	70 (64,)
	71 (64,)
	72 (64,)
	73 (64,)
	L14
	74 (4, 4, 128, 4)
	75 (3,)
*/

#include <stdlib.h>
#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <random>
#include <fstream>
#include <iostream>

using namespace std;
using namespace cv;
using namespace cv::ml;

// Avoid default to_str method
template < typename Type > string to_str(const Type & t)
{
	ostringstream os;
	os << t;
	return os.str();
}

class pix2pix {
private:
	float epsilon;
	float ***image;
	// Weights and biases
	float ****wl1;
	float *bl1;
	float ****wl2;
	float *bl2;
	float **nl2;
	float ****wl3;
	float *bl3;
	float **nl3;
	float ****wl4;
	float *bl4;
	float **nl4;
	float ****wl5;
	float *bl5;
	float **nl5;
	float ****wl6;
	float *bl6;
	float **nl6;
	float ****wl7;
	float *bl7;
	float **nl7;
	float ****wl8;
	float *bl8;
	float **nl8;
	float ****wl9;
	float *bl9;
	float **nl9;
	float ****wl10;
	float *bl10;
	float **nl10;
	float ****wl11;
	float *bl11;
	float **nl11;
	float ****wl12;
	float *bl12;
	float **nl12;
	float ****wl13;
	float *bl13;
	float **nl13;
	float ****wl14;
	float *bl14;

	// Outputs
	float ***l1;
	float ***l2;
	float ***l3;
	float ***l4;
	float ***l5;
	float ***l6;
	float ***l7;
	float ***l8;
	float ***l9;
	float ***l10;
	float ***l11;
	float ***l12;
	float ***l13;
	float ***l14;

	void getWeights(ifstream *fin, float ****a, int mi, int mj, int mk, int ml)
	{
		for (int i = 0; i < mi; i++) {
			for (int j = 0; j < mj; j++) {
				for (int k = 0; k < mk; k++) {
					fin->read(reinterpret_cast<char*>(a[i][j][k]), sizeof(float) * ml);
				}
			}
		}
	}

	void getBias(ifstream *fin, float *a, int mi)
	{
		fin->read(reinterpret_cast<char*>(a), sizeof(float) * mi);
	}

	void getNorm(ifstream *fin, float **n, int mj)
	{
		for (int i = 0; i < 4; i++) {
			fin->read(reinterpret_cast<char*>(n[i]), sizeof(float) * mj);
		}
	}

	inline int clamp(int x, int l, int h)
	{
		return x < l ? l : (x > h ? h : x);
	}

	inline float leakyrelu(float x, float alpha)
	{
		// leaky relu
		return x < 0.0f ? alpha * x : x;
	}

	inline float relu(float x)
	{
		// relu
		return max(x, 0.0f);
	}

	// padded get
	inline float getLayer(float ***a, int x, int y, int z, int min, int max)
	{
		float r = a[clamp(x, min, max)][clamp(y, min, max)][z];
		r = (x < min || x > max) ? 0.0f : r;
		r = (y < min || y > max) ? 0.0f : r;
		return r;
	}

	inline float batchNorm(float x, float gamma, float beta, float mean, float var)
	{
		return ((x - mean) / sqrtf(var + epsilon)) * gamma + beta;
	}

public:
	// Annoying callocs
	static void** createArray(int i, int j, size_t size)
	{
		void** r = (void**)calloc(i, sizeof(void*));
		for (int x = 0; x < i; x++) {
			r[x] = (void*)calloc(j, size);
		}
		return r;
	}

	static void*** createArray(int i, int j, int k, size_t size)
	{
		void*** r = (void***)calloc(i, sizeof(void*));
		for (int x = 0; x < i; x++) {
			r[x] = (void**)calloc(j, sizeof(void*));
			for (int y = 0; y < j; y++) {
				r[x][y] = (void*)calloc(k, size);
			}
		}
		return r;
	}

	static void**** createArray(int i, int j, int k, int l, size_t size)
	{
		void**** r = (void****)calloc(i, sizeof(void*));
		for (int x = 0; x < i; x++) {
			r[x] = (void***)calloc(j, sizeof(void*));
			for (int y = 0; y < j; y++) {
				r[x][y] = (void**)calloc(k, sizeof(void*));
				for (int z = 0; z < k; z++) {
					r[x][y][z] = (void*)calloc(l, size);
				}
			}
		}
		return r;
	}

	// Annoying calloc frees
	static void freeArray(int i, int j, void** a)
	{
		for (int x = 0; x < i; x++) {
			free(a[x]);
		}
		free(a);
	}

	static void freeArray(int i, int j, int k, void*** a)
	{
		for (int x = 0; x < i; x++) {
			for (int y = 0; y < j; y++) {
				free(a[x][y]);
			}
			free(a[x]);
		}
		free(a);
	}

	static void freeArray(int i, int j, int k, int l, void**** a)
	{
		for (int x = 0; x < i; x++) {
			for (int y = 0; y < j; y++) {
				for (int z = 0; z < k; z++) {
					free(a[x][y][z]);
				}
				free(a[x][y]);
			}
			free(a[x]);
		}
		free(a);
	}

	pix2pix(string path)
	{
		epsilon = 0.001f;

		l1 = (float***)createArray(128, 128, 64, sizeof(float));
		l2 = (float***)createArray(64, 64, 64, sizeof(float));
		l3 = (float***)createArray(32, 32, 128, sizeof(float));
		l4 = (float***)createArray(16, 16, 256, sizeof(float));
		l5 = (float***)createArray(8, 8, 256, sizeof(float));
		l6 = (float***)createArray(4, 4, 256, sizeof(float));
		l7 = (float***)createArray(2, 2, 512, sizeof(float));
		l8 = (float***)createArray(4, 4, 512, sizeof(float));
		l9 = (float***)createArray(8, 8, 256, sizeof(float));
		l10 = (float***)createArray(16, 16, 256, sizeof(float));
		l11 = (float***)createArray(32, 32, 128, sizeof(float));
		l12 = (float***)createArray(64, 64, 64, sizeof(float));
		l13 = (float***)createArray(128, 128, 64, sizeof(float));
		l14 = (float***)createArray(256, 256, 3, sizeof(float));

		wl1 = (float****)createArray(4, 4, 3, 64, sizeof(float));
		bl1 = (float*)calloc(64, sizeof(float));

		wl2 = (float****)createArray(4, 4, 64, 64, sizeof(float));
		bl2 = (float*)calloc(64, sizeof(float));
		nl2 = (float**)createArray(4, 64, sizeof(float));

		wl3 = (float****)createArray(4, 4, 64, 128, sizeof(float));
		bl3 = (float*)calloc(128, sizeof(float));
		nl3 = (float**)createArray(4, 128, sizeof(float));

		wl4 = (float****)createArray(4, 4, 128, 256, sizeof(float));
		bl4 = (float*)calloc(256, sizeof(float));
		nl4 = (float**)createArray(4, 256, sizeof(float));

		wl5 = (float****)createArray(4, 4, 256, 256, sizeof(float));
		bl5 = (float*)calloc(256, sizeof(float));
		nl5 = (float**)createArray(4, 256, sizeof(float));

		wl6 = (float****)createArray(4, 4, 256, 256, sizeof(float));
		bl6 = (float*)calloc(256, sizeof(float));
		nl6 = (float**)createArray(4, 256, sizeof(float));

		wl7 = (float****)createArray(4, 4, 256, 512, sizeof(float));
		bl7 = (float*)calloc(512, sizeof(float));
		nl7 = (float**)createArray(4, 512, sizeof(float));

		wl8 = (float****)createArray(4, 4, 512, 512, sizeof(float));
		bl8 = (float*)calloc(512, sizeof(float));
		nl8 = (float**)createArray(4, 512, sizeof(float));

		wl9 = (float****)createArray(4, 4, 768, 256, sizeof(float));
		bl9 = (float*)calloc(256, sizeof(float));
		nl9 = (float**)createArray(4, 256, sizeof(float));

		wl10 = (float****)createArray(4, 4, 512, 256, sizeof(float));
		bl10 = (float*)calloc(256, sizeof(float));
		nl10 = (float**)createArray(4, 256, sizeof(float));

		wl11 = (float****)createArray(4, 4, 512, 128, sizeof(float));
		bl11 = (float*)calloc(128, sizeof(float));
		nl11 = (float**)createArray(4, 128, sizeof(float));

		wl12 = (float****)createArray(4, 4, 256, 64, sizeof(float));
		bl12 = (float*)calloc(64, sizeof(float));
		nl12 = (float**)createArray(4, 64, sizeof(float));

		wl13 = (float****)createArray(4, 4, 128, 64, sizeof(float));
		bl13 = (float*)calloc(64, sizeof(float));
		nl13 = (float**)createArray(4, 64, sizeof(float));

		wl14 = (float****)createArray(4, 4, 128, 4, sizeof(float));
		bl14 = (float*)calloc(3, sizeof(float));

		cout << "loading weight list: " << path << endl;

		ifstream fin(path, ios::binary);
		if (!fin) {
			cout << "error opening stream" << endl;
			exit(-1);
		}

		// L1
		getWeights(&fin, wl1, 4, 4, 3, 64);
		getBias(&fin, bl1, 64);

		// L2
		getWeights(&fin, wl2, 4, 4, 64, 64);
		getBias(&fin, bl2, 64);
		getNorm(&fin, nl2, 64);

		// L3
		getWeights(&fin, wl3, 4, 4, 64, 128);
		getBias(&fin, bl3, 128);
		getNorm(&fin, nl3, 128);

		// L4
		getWeights(&fin, wl4, 4, 4, 128, 256);
		getBias(&fin, bl4, 256);
		getNorm(&fin, nl4, 256);

		// L5
		getWeights(&fin, wl5, 4, 4, 256, 256);
		getBias(&fin, bl5, 256);
		getNorm(&fin, nl5, 256);

		// L6
		getWeights(&fin, wl6, 4, 4, 256, 256);
		getBias(&fin, bl6, 256);
		getNorm(&fin, nl6, 256);

		// L7
		getWeights(&fin, wl7, 4, 4, 256, 512);
		getBias(&fin, bl7, 512);
		getNorm(&fin, nl7, 512);

		// L8
		getWeights(&fin, wl8, 4, 4, 512, 512);
		getBias(&fin, bl8, 512);
		getNorm(&fin, nl8, 512);

		// L9
		getWeights(&fin, wl9, 4, 4, 768, 256);
		getBias(&fin, bl9, 256);
		getNorm(&fin, nl9, 256);

		// L10
		getWeights(&fin, wl10, 4, 4, 512, 256);
		getBias(&fin, bl10, 256);
		getNorm(&fin, nl10, 256);

		// L11
		getWeights(&fin, wl11, 4, 4, 512, 128);
		getBias(&fin, bl11, 128);
		getNorm(&fin, nl11, 128);

		// L12
		getWeights(&fin, wl12, 4, 4, 256, 64);
		getBias(&fin, bl12, 64);
		getNorm(&fin, nl12, 64);

		// L13
		getWeights(&fin, wl13, 4, 4, 128, 64);
		getBias(&fin, bl13, 64);
		getNorm(&fin, nl13, 64);

		// L14
		getWeights(&fin, wl14, 4, 4, 128, 4);
		getBias(&fin, bl14, 3);

		fin.close();
	}

	~pix2pix()
	{
		freeArray(128, 128, 64, (void***)l1);
		freeArray(64, 64, 64, (void***)l2);
		freeArray(32, 32, 128, (void***)l3);
		freeArray(16, 16, 256, (void***)l4);
		freeArray(8, 8, 256, (void***)l5);
		freeArray(4, 4, 256, (void***)l6);
		freeArray(2, 2, 512, (void***)l7);
		freeArray(4, 4, 512, (void***)l8);
		freeArray(8, 8, 256, (void***)l9);
		freeArray(16, 16, 256, (void***)l10);
		freeArray(32, 32, 128, (void***)l11);
		freeArray(64, 64, 64, (void***)l12);
		freeArray(128, 128, 64, (void***)l13);
		freeArray(256, 256, 3, (void***)l14);

		freeArray(4, 4, 3, 64, (void****)wl1);
		freeArray(4, 4, 64, 64, (void****)wl2);
		freeArray(4, 4, 64, 128, (void****)wl3);
		freeArray(4, 4, 128, 256, (void****)wl4);
		freeArray(4, 4, 256, 256, (void****)wl5);
		freeArray(4, 4, 256, 256, (void****)wl6);
		freeArray(4, 4, 256, 512, (void****)wl7);
		freeArray(4, 4, 512, 512, (void****)wl8);
		freeArray(4, 4, 768, 256, (void****)wl9);
		freeArray(4, 4, 512, 256, (void****)wl10);
		freeArray(4, 4, 512, 128, (void****)wl11);
		freeArray(4, 4, 256, 64, (void****)wl12);
		freeArray(4, 4, 128, 64, (void****)wl13);
		freeArray(4, 4, 128, 4, (void****)wl14);

		free(bl1);
		free(bl2);
		free(bl3);
		free(bl4);
		free(bl5);
		free(bl6);
		free(bl7);
		free(bl8);
		free(bl9);
		free(bl10);
		free(bl11);
		free(bl12);
		free(bl13);
		free(bl14);

		freeArray(4, 64, (void**)nl2);
		freeArray(4, 128, (void**)nl3);
		freeArray(4, 256, (void**)nl4);
		freeArray(4, 256, (void**)nl5);
		freeArray(4, 256, (void**)nl6);
		freeArray(4, 512, (void**)nl7);
		freeArray(4, 512, (void**)nl8);
		freeArray(4, 256, (void**)nl9);
		freeArray(4, 256, (void**)nl10);
		freeArray(4, 128, (void**)nl11);
		freeArray(4, 64, (void**)nl12);
		freeArray(4, 64, (void**)nl13);
	}

	void forwardProp(float*** imageIn, float***imageOut)
	{
		// use getter function
		image = imageIn;

		// L1, kernel=4x4, stride=2, padding=1
		for (int k = 0; k < 64; k++) {
			for (int i = 0; i < 128; i++) {
				for (int j = 0; j < 128; j++) {

					l1[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 3; l++) {
						l1[i][j][k] +=
							getLayer(image, i0, j0, l, 0, 255) * wl1[0][0][l][k] +
							getLayer(image, i0, j1, l, 0, 255) * wl1[0][1][l][k] +
							getLayer(image, i0, j2, l, 0, 255) * wl1[0][2][l][k] +
							getLayer(image, i0, j3, l, 0, 255) * wl1[0][3][l][k] +
							getLayer(image, i1, j0, l, 0, 255) * wl1[1][0][l][k] +
							getLayer(image, i1, j1, l, 0, 255) * wl1[1][1][l][k] +
							getLayer(image, i1, j2, l, 0, 255) * wl1[1][2][l][k] +
							getLayer(image, i1, j3, l, 0, 255) * wl1[1][3][l][k] +
							getLayer(image, i2, j0, l, 0, 255) * wl1[2][0][l][k] +
							getLayer(image, i2, j1, l, 0, 255) * wl1[2][1][l][k] +
							getLayer(image, i2, j2, l, 0, 255) * wl1[2][2][l][k] +
							getLayer(image, i2, j3, l, 0, 255) * wl1[2][3][l][k] +
							getLayer(image, i3, j0, l, 0, 255) * wl1[3][0][l][k] +
							getLayer(image, i3, j1, l, 0, 255) * wl1[3][1][l][k] +
							getLayer(image, i3, j2, l, 0, 255) * wl1[3][2][l][k] +
							getLayer(image, i3, j3, l, 0, 255) * wl1[3][3][l][k];
					}

					l1[i][j][k] += bl1[k]; // bias
					l1[i][j][k] = leakyrelu(l1[i][j][k], 0.2f); // activation
				}
			}
		}

		cout << "L1 done" << endl;

		// L2, kernel=4x4, stride=2, padding=1
		for (int k = 0; k < 64; k++) {
			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {

					l2[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 64; l++) {
						l2[i][j][k] +=
							getLayer(l1, i0, j0, l, 0, 127) * wl2[0][0][l][k] +
							getLayer(l1, i0, j1, l, 0, 127) * wl2[0][1][l][k] +
							getLayer(l1, i0, j2, l, 0, 127) * wl2[0][2][l][k] +
							getLayer(l1, i0, j3, l, 0, 127) * wl2[0][3][l][k] +
							getLayer(l1, i1, j0, l, 0, 127) * wl2[1][0][l][k] +
							getLayer(l1, i1, j1, l, 0, 127) * wl2[1][1][l][k] +
							getLayer(l1, i1, j2, l, 0, 127) * wl2[1][2][l][k] +
							getLayer(l1, i1, j3, l, 0, 127) * wl2[1][3][l][k] +
							getLayer(l1, i2, j0, l, 0, 127) * wl2[2][0][l][k] +
							getLayer(l1, i2, j1, l, 0, 127) * wl2[2][1][l][k] +
							getLayer(l1, i2, j2, l, 0, 127) * wl2[2][2][l][k] +
							getLayer(l1, i2, j3, l, 0, 127) * wl2[2][3][l][k] +
							getLayer(l1, i3, j0, l, 0, 127) * wl2[3][0][l][k] +
							getLayer(l1, i3, j1, l, 0, 127) * wl2[3][1][l][k] +
							getLayer(l1, i3, j2, l, 0, 127) * wl2[3][2][l][k] +
							getLayer(l1, i3, j3, l, 0, 127) * wl2[3][3][l][k];
					}

					l2[i][j][k] += bl2[k]; // bias
					l2[i][j][k] = leakyrelu(l2[i][j][k], 0.2f); // activation
				}
			}
		}

		// L2 layer normalization, activation
		float rmeanl2[64] = { 0.0f };
		float rvarl2[64] = { 0.0f };
		for (int k = 0; k < 64; k++) {

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					rmeanl2[k] += l2[i][j][k];
				}
			}
			rmeanl2[k] /= 4096.0f; // 64 * 64

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					rvarl2[k] += powf(l2[i][j][k] - rmeanl2[k], 2);
				}
			}
			rvarl2[k] /= 4096.0f; // 64 * 64

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					// normalization
					//z1_hat = (x - pop_mean) / sqrt(pop_var + epsilon)
					//	BN1 = gamma * z1_hat + beta
					l2[i][j][k] = batchNorm(l2[i][j][k], nl2[0][k], nl2[1][k],
						rmeanl2[k], rvarl2[k]);
				}
			}
		}

		cout << "L2 done" << endl;

		// L3, kernel=4x4, stride=2, padding=1
		for (int k = 0; k < 128; k++) {
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {

					l3[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 64; l++) {
						l3[i][j][k] +=
							getLayer(l2, i0, j0, l, 0, 63) * wl3[0][0][l][k] +
							getLayer(l2, i0, j1, l, 0, 63) * wl3[0][1][l][k] +
							getLayer(l2, i0, j2, l, 0, 63) * wl3[0][2][l][k] +
							getLayer(l2, i0, j3, l, 0, 63) * wl3[0][3][l][k] +
							getLayer(l2, i1, j0, l, 0, 63) * wl3[1][0][l][k] +
							getLayer(l2, i1, j1, l, 0, 63) * wl3[1][1][l][k] +
							getLayer(l2, i1, j2, l, 0, 63) * wl3[1][2][l][k] +
							getLayer(l2, i1, j3, l, 0, 63) * wl3[1][3][l][k] +
							getLayer(l2, i2, j0, l, 0, 63) * wl3[2][0][l][k] +
							getLayer(l2, i2, j1, l, 0, 63) * wl3[2][1][l][k] +
							getLayer(l2, i2, j2, l, 0, 63) * wl3[2][2][l][k] +
							getLayer(l2, i2, j3, l, 0, 63) * wl3[2][3][l][k] +
							getLayer(l2, i3, j0, l, 0, 63) * wl3[3][0][l][k] +
							getLayer(l2, i3, j1, l, 0, 63) * wl3[3][1][l][k] +
							getLayer(l2, i3, j2, l, 0, 63) * wl3[3][2][l][k] +
							getLayer(l2, i3, j3, l, 0, 63) * wl3[3][3][l][k];
					}

					l3[i][j][k] += bl3[k]; // bias
					l3[i][j][k] = leakyrelu(l3[i][j][k], 0.2f); // activation
				}
			}
		}

		// L3 layer normalization, activation
		float rmeanl3[128] = { 0.0f };
		float rvarl3[128] = { 0.0f };
		for (int k = 0; k < 128; k++) {

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					rmeanl3[k] += l3[i][j][k];
				}
			}
			rmeanl3[k] /= 1024.0f; // 32 * 32

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					rvarl3[k] += powf(l3[i][j][k] - rmeanl3[k], 2);
				}
			}
			rvarl3[k] /= 1024.0f; // 32 * 32

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					// normalization
					l3[i][j][k] = batchNorm(l3[i][j][k], nl3[0][k], nl3[1][k],
						rmeanl3[k], rvarl3[k]);
				}
			}
		}

		cout << "L3 done" << endl;

		// L4, kernel=4x4, stride=2, padding=1, batch norm
		for (int k = 0; k < 256; k++) {
			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {

					l4[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 128; l++) {
						l4[i][j][k] +=
							getLayer(l3, i0, j0, l, 0, 31) * wl4[0][0][l][k] +
							getLayer(l3, i0, j1, l, 0, 31) * wl4[0][1][l][k] +
							getLayer(l3, i0, j2, l, 0, 31) * wl4[0][2][l][k] +
							getLayer(l3, i0, j3, l, 0, 31) * wl4[0][3][l][k] +
							getLayer(l3, i1, j0, l, 0, 31) * wl4[1][0][l][k] +
							getLayer(l3, i1, j1, l, 0, 31) * wl4[1][1][l][k] +
							getLayer(l3, i1, j2, l, 0, 31) * wl4[1][2][l][k] +
							getLayer(l3, i1, j3, l, 0, 31) * wl4[1][3][l][k] +
							getLayer(l3, i2, j0, l, 0, 31) * wl4[2][0][l][k] +
							getLayer(l3, i2, j1, l, 0, 31) * wl4[2][1][l][k] +
							getLayer(l3, i2, j2, l, 0, 31) * wl4[2][2][l][k] +
							getLayer(l3, i2, j3, l, 0, 31) * wl4[2][3][l][k] +
							getLayer(l3, i3, j0, l, 0, 31) * wl4[3][0][l][k] +
							getLayer(l3, i3, j1, l, 0, 31) * wl4[3][1][l][k] +
							getLayer(l3, i3, j2, l, 0, 31) * wl4[3][2][l][k] +
							getLayer(l3, i3, j3, l, 0, 31) * wl4[3][3][l][k];
					}

					l4[i][j][k] += bl4[k]; // bias
					l4[i][j][k] = leakyrelu(l4[i][j][k], 0.2f); // activation
				}
			}
		}

		// L4 layer normalization, activation
		float rmeanl4[256] = { 0.0f };
		float rvarl4[256] = { 0.0f };
		for (int k = 0; k < 256; k++) {

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					rmeanl4[k] += l4[i][j][k];
				}
			}
			rmeanl4[k] /= 256.0f; // 16 * 16

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					rvarl4[k] += powf(l4[i][j][k] - rmeanl4[k], 2);
				}
			}
			rvarl4[k] /= 256.0f; // 16 * 16

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					// normalization
					l4[i][j][k] = batchNorm(l4[i][j][k], nl4[0][k], nl4[1][k],
						rmeanl4[k], rvarl4[k]);
				}
			}
		}

		cout << "L4 done" << endl;

		// L5, kernel=4x4, stride=2, padding=1, batch norm
		for (int k = 0; k < 256; k++) {
			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {

					l5[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 256; l++) {
						l5[i][j][k] +=
							getLayer(l4, i0, j0, l, 0, 15) * wl5[0][0][l][k] +
							getLayer(l4, i0, j1, l, 0, 15) * wl5[0][1][l][k] +
							getLayer(l4, i0, j2, l, 0, 15) * wl5[0][2][l][k] +
							getLayer(l4, i0, j3, l, 0, 15) * wl5[0][3][l][k] +
							getLayer(l4, i1, j0, l, 0, 15) * wl5[1][0][l][k] +
							getLayer(l4, i1, j1, l, 0, 15) * wl5[1][1][l][k] +
							getLayer(l4, i1, j2, l, 0, 15) * wl5[1][2][l][k] +
							getLayer(l4, i1, j3, l, 0, 15) * wl5[1][3][l][k] +
							getLayer(l4, i2, j0, l, 0, 15) * wl5[2][0][l][k] +
							getLayer(l4, i2, j1, l, 0, 15) * wl5[2][1][l][k] +
							getLayer(l4, i2, j2, l, 0, 15) * wl5[2][2][l][k] +
							getLayer(l4, i2, j3, l, 0, 15) * wl5[2][3][l][k] +
							getLayer(l4, i3, j0, l, 0, 15) * wl5[3][0][l][k] +
							getLayer(l4, i3, j1, l, 0, 15) * wl5[3][1][l][k] +
							getLayer(l4, i3, j2, l, 0, 15) * wl5[3][2][l][k] +
							getLayer(l4, i3, j3, l, 0, 15) * wl5[3][3][l][k];
					}

					l5[i][j][k] += bl5[k]; // bias
					l5[i][j][k] = leakyrelu(l5[i][j][k], 0.2f); // activation
				}
			}
		}

		// L5 layer normalization, activation
		float rmeanl5[256] = { 0.0f };
		float rvarl5[256] = { 0.0f };
		for (int k = 0; k < 256; k++) {

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					rmeanl5[k] += l5[i][j][k];
				}
			}
			rmeanl5[k] /= 64.0f; // 8 * 8

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					rvarl5[k] += powf(l5[i][j][k] - rmeanl5[k], 2);
				}
			}
			rvarl5[k] /= 64.0f; // 8 * 8

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					// normalization
					l5[i][j][k] = batchNorm(l5[i][j][k], nl5[0][k], nl5[1][k],
						rmeanl5[k], rvarl5[k]);
				}
			}
		}

		cout << "L5 done" << endl;

		// L6, kernel=4x4, stride=2, padding=1, batch norm
		for (int k = 0; k < 256; k++) {
			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {

					l6[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 256; l++) {
						l6[i][j][k] +=
							getLayer(l5, i0, j0, l, 0, 7) * wl6[0][0][l][k] +
							getLayer(l5, i0, j1, l, 0, 7) * wl6[0][1][l][k] +
							getLayer(l5, i0, j2, l, 0, 7) * wl6[0][2][l][k] +
							getLayer(l5, i0, j3, l, 0, 7) * wl6[0][3][l][k] +
							getLayer(l5, i1, j0, l, 0, 7) * wl6[1][0][l][k] +
							getLayer(l5, i1, j1, l, 0, 7) * wl6[1][1][l][k] +
							getLayer(l5, i1, j2, l, 0, 7) * wl6[1][2][l][k] +
							getLayer(l5, i1, j3, l, 0, 7) * wl6[1][3][l][k] +
							getLayer(l5, i2, j0, l, 0, 7) * wl6[2][0][l][k] +
							getLayer(l5, i2, j1, l, 0, 7) * wl6[2][1][l][k] +
							getLayer(l5, i2, j2, l, 0, 7) * wl6[2][2][l][k] +
							getLayer(l5, i2, j3, l, 0, 7) * wl6[2][3][l][k] +
							getLayer(l5, i3, j0, l, 0, 7) * wl6[3][0][l][k] +
							getLayer(l5, i3, j1, l, 0, 7) * wl6[3][1][l][k] +
							getLayer(l5, i3, j2, l, 0, 7) * wl6[3][2][l][k] +
							getLayer(l5, i3, j3, l, 0, 7) * wl6[3][3][l][k];
					}

					l6[i][j][k] += bl6[k]; // bias
					l6[i][j][k] = leakyrelu(l6[i][j][k], 0.2f); // activation
				}
			}
		}

		// L6 layer normalization, activation
		float rmeanl6[256] = { 0.0f };
		float rvarl6[256] = { 0.0f };
		for (int k = 0; k < 256; k++) {

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					rmeanl6[k] += l6[i][j][k];
				}
			}
			rmeanl6[k] /= 16.0f; // 4 * 4

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					rvarl6[k] += powf(l6[i][j][k] - rmeanl6[k], 2);
				}
			}
			rvarl6[k] /= 16.0f; // 4 * 4

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					// normalization
					l6[i][j][k] = batchNorm(l6[i][j][k], nl6[0][k], nl6[1][k],
						rmeanl6[k], rvarl6[k]);
				}
			}
		}

		cout << "L6 done" << endl;

		// L7, kernel=4x4, stride=2, padding=1, batch norm
		for (int k = 0; k < 512; k++) {
			for (int i = 0; i < 2; i++) {
				for (int j = 0; j < 2; j++) {

					l7[i][j][k] = 0.0f;
					int i1 = i * 2, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j * 2, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// kernel
					for (int l = 0; l < 256; l++) {
						l7[i][j][k] +=
							getLayer(l6, i0, j0, l, 0, 3) * wl7[0][0][l][k] +
							getLayer(l6, i0, j1, l, 0, 3) * wl7[0][1][l][k] +
							getLayer(l6, i0, j2, l, 0, 3) * wl7[0][2][l][k] +
							getLayer(l6, i0, j3, l, 0, 3) * wl7[0][3][l][k] +
							getLayer(l6, i1, j0, l, 0, 3) * wl7[1][0][l][k] +
							getLayer(l6, i1, j1, l, 0, 3) * wl7[1][1][l][k] +
							getLayer(l6, i1, j2, l, 0, 3) * wl7[1][2][l][k] +
							getLayer(l6, i1, j3, l, 0, 3) * wl7[1][3][l][k] +
							getLayer(l6, i2, j0, l, 0, 3) * wl7[2][0][l][k] +
							getLayer(l6, i2, j1, l, 0, 3) * wl7[2][1][l][k] +
							getLayer(l6, i2, j2, l, 0, 3) * wl7[2][2][l][k] +
							getLayer(l6, i2, j3, l, 0, 3) * wl7[2][3][l][k] +
							getLayer(l6, i3, j0, l, 0, 3) * wl7[3][0][l][k] +
							getLayer(l6, i3, j1, l, 0, 3) * wl7[3][1][l][k] +
							getLayer(l6, i3, j2, l, 0, 3) * wl7[3][2][l][k] +
							getLayer(l6, i3, j3, l, 0, 3) * wl7[3][3][l][k];
					}

					l7[i][j][k] += bl7[k]; // bias
					l7[i][j][k] = leakyrelu(l7[i][j][k], 0.2f); // activation
				}
			}
		}

		// L7 layer normalization, activation
		float rmeanl7[512] = { 0.0f };
		float rvarl7[512] = { 0.0f };
		for (int k = 0; k < 512; k++) {

			for (int i = 0; i < 2; i++) {
				for (int j = 0; j < 2; j++) {
					rmeanl7[k] += l7[i][j][k];
				}
			}
			rmeanl7[k] /= 4.0f; // 2 * 2

			for (int i = 0; i < 2; i++) {
				for (int j = 0; j < 2; j++) {
					rvarl7[k] += powf(l7[i][j][k] - rmeanl7[k], 2);
				}
			}
			rvarl7[k] /= 4.0f; // 2 * 2

			for (int i = 0; i < 2; i++) {
				for (int j = 0; j < 2; j++) {
					// normalization
					l7[i][j][k] = batchNorm(l7[i][j][k], nl7[0][k], nl7[1][k],
						rmeanl7[k], rvarl7[k]);
				}
			}
		}

		cout << "L7 done" << endl;

		// L8, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 512; k++) {
			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {

					l8[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 512; l++) {
						l8[i][j][k] +=
							getLayer(l7, i0, j0, l, 0, 1) * wl8[0][0][l][k] +
							getLayer(l7, i0, j1, l, 0, 1) * wl8[0][1][l][k] +
							getLayer(l7, i0, j2, l, 0, 1) * wl8[0][2][l][k] +
							getLayer(l7, i0, j3, l, 0, 1) * wl8[0][3][l][k] +
							getLayer(l7, i1, j0, l, 0, 1) * wl8[1][0][l][k] +
							getLayer(l7, i1, j1, l, 0, 1) * wl8[1][1][l][k] +
							getLayer(l7, i1, j2, l, 0, 1) * wl8[1][2][l][k] +
							getLayer(l7, i1, j3, l, 0, 1) * wl8[1][3][l][k] +
							getLayer(l7, i2, j0, l, 0, 1) * wl8[2][0][l][k] +
							getLayer(l7, i2, j1, l, 0, 1) * wl8[2][1][l][k] +
							getLayer(l7, i2, j2, l, 0, 1) * wl8[2][2][l][k] +
							getLayer(l7, i2, j3, l, 0, 1) * wl8[2][3][l][k] +
							getLayer(l7, i3, j0, l, 0, 1) * wl8[3][0][l][k] +
							getLayer(l7, i3, j1, l, 0, 1) * wl8[3][1][l][k] +
							getLayer(l7, i3, j2, l, 0, 1) * wl8[3][2][l][k] +
							getLayer(l7, i3, j3, l, 0, 1) * wl8[3][3][l][k];
					}

					l8[i][j][k] += bl8[k]; // bias
					l8[i][j][k] = relu(l8[i][j][k]); // activation
				}
			}
		}

		// L8 layer normalization, activation
		float rmeanl8[512] = { 0.0f };
		float rvarl8[512] = { 0.0f };
		for (int k = 0; k < 512; k++) {

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					rmeanl8[k] += l8[i][j][k];
				}
			}
			rmeanl8[k] /= 16.0f; // 4 * 4

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					rvarl8[k] += powf(l8[i][j][k] - rmeanl8[k], 2);
				}
			}
			rvarl8[k] /= 16.0f; // 4 * 4

			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 4; j++) {
					// normalization
					l8[i][j][k] = batchNorm(l8[i][j][k], nl8[0][k], nl8[1][k],
						rmeanl8[k], rvarl8[k]);
				}
			}
		}

		cout << "L8 done" << endl;

		// L9, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 256; k++) {
			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {

					l9[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 512; l++) {
						l9[i][j][k] +=
							getLayer(l8, i0, j0, l, 0, 3) * wl9[0][0][l][k] +
							getLayer(l8, i0, j1, l, 0, 3) * wl9[0][1][l][k] +
							getLayer(l8, i0, j2, l, 0, 3) * wl9[0][2][l][k] +
							getLayer(l8, i0, j3, l, 0, 3) * wl9[0][3][l][k] +
							getLayer(l8, i1, j0, l, 0, 3) * wl9[1][0][l][k] +
							getLayer(l8, i1, j1, l, 0, 3) * wl9[1][1][l][k] +
							getLayer(l8, i1, j2, l, 0, 3) * wl9[1][2][l][k] +
							getLayer(l8, i1, j3, l, 0, 3) * wl9[1][3][l][k] +
							getLayer(l8, i2, j0, l, 0, 3) * wl9[2][0][l][k] +
							getLayer(l8, i2, j1, l, 0, 3) * wl9[2][1][l][k] +
							getLayer(l8, i2, j2, l, 0, 3) * wl9[2][2][l][k] +
							getLayer(l8, i2, j3, l, 0, 3) * wl9[2][3][l][k] +
							getLayer(l8, i3, j0, l, 0, 3) * wl9[3][0][l][k] +
							getLayer(l8, i3, j1, l, 0, 3) * wl9[3][1][l][k] +
							getLayer(l8, i3, j2, l, 0, 3) * wl9[3][2][l][k] +
							getLayer(l8, i3, j3, l, 0, 3) * wl9[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 512; l < 768; l++) {
						l9[i][j][k] +=
							getLayer(l6, i0, j0, l - 512, 0, 3) * wl9[0][0][l][k] +
							getLayer(l6, i0, j1, l - 512, 0, 3) * wl9[0][1][l][k] +
							getLayer(l6, i0, j2, l - 512, 0, 3) * wl9[0][2][l][k] +
							getLayer(l6, i0, j3, l - 512, 0, 3) * wl9[0][3][l][k] +
							getLayer(l6, i1, j0, l - 512, 0, 3) * wl9[1][0][l][k] +
							getLayer(l6, i1, j1, l - 512, 0, 3) * wl9[1][1][l][k] +
							getLayer(l6, i1, j2, l - 512, 0, 3) * wl9[1][2][l][k] +
							getLayer(l6, i1, j3, l - 512, 0, 3) * wl9[1][3][l][k] +
							getLayer(l6, i2, j0, l - 512, 0, 3) * wl9[2][0][l][k] +
							getLayer(l6, i2, j1, l - 512, 0, 3) * wl9[2][1][l][k] +
							getLayer(l6, i2, j2, l - 512, 0, 3) * wl9[2][2][l][k] +
							getLayer(l6, i2, j3, l - 512, 0, 3) * wl9[2][3][l][k] +
							getLayer(l6, i3, j0, l - 512, 0, 3) * wl9[3][0][l][k] +
							getLayer(l6, i3, j1, l - 512, 0, 3) * wl9[3][1][l][k] +
							getLayer(l6, i3, j2, l - 512, 0, 3) * wl9[3][2][l][k] +
							getLayer(l6, i3, j3, l - 512, 0, 3) * wl9[3][3][l][k];
					}

					l9[i][j][k] += bl9[k]; // bias
					l9[i][j][k] = relu(l9[i][j][k]); // activation
				}
			}
		}

		// L9 layer normalization, activation
		float rmeanl9[256] = { 0.0f };
		float rvarl9[256] = { 0.0f };
		for (int k = 0; k < 256; k++) {

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					rmeanl9[k] += l9[i][j][k];
				}
			}
			rmeanl9[k] /= 64.0f; // 8 * 8

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					rvarl9[k] += powf(l9[i][j][k] - rmeanl9[k], 2);
				}
			}
			rvarl9[k] /= 64.0f; // 8 * 8

			for (int i = 0; i < 8; i++) {
				for (int j = 0; j < 8; j++) {
					// normalization
					l9[i][j][k] = batchNorm(l9[i][j][k], nl9[0][k], nl9[1][k],
						rmeanl9[k], rvarl9[k]);
				}
			}
		}

		cout << "L9 done" << endl;

		// L10, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 256; k++) {
			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {

					l10[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 256; l++) {
						l10[i][j][k] +=
							getLayer(l9, i0, j0, l, 0, 7) * wl10[0][0][l][k] +
							getLayer(l9, i0, j1, l, 0, 7) * wl10[0][1][l][k] +
							getLayer(l9, i0, j2, l, 0, 7) * wl10[0][2][l][k] +
							getLayer(l9, i0, j3, l, 0, 7) * wl10[0][3][l][k] +
							getLayer(l9, i1, j0, l, 0, 7) * wl10[1][0][l][k] +
							getLayer(l9, i1, j1, l, 0, 7) * wl10[1][1][l][k] +
							getLayer(l9, i1, j2, l, 0, 7) * wl10[1][2][l][k] +
							getLayer(l9, i1, j3, l, 0, 7) * wl10[1][3][l][k] +
							getLayer(l9, i2, j0, l, 0, 7) * wl10[2][0][l][k] +
							getLayer(l9, i2, j1, l, 0, 7) * wl10[2][1][l][k] +
							getLayer(l9, i2, j2, l, 0, 7) * wl10[2][2][l][k] +
							getLayer(l9, i2, j3, l, 0, 7) * wl10[2][3][l][k] +
							getLayer(l9, i3, j0, l, 0, 7) * wl10[3][0][l][k] +
							getLayer(l9, i3, j1, l, 0, 7) * wl10[3][1][l][k] +
							getLayer(l9, i3, j2, l, 0, 7) * wl10[3][2][l][k] +
							getLayer(l9, i3, j3, l, 0, 7) * wl10[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 256; l < 512; l++) {
						l10[i][j][k] +=
							getLayer(l5, i0, j0, l - 256, 0, 7) * wl10[0][0][l][k] +
							getLayer(l5, i0, j1, l - 256, 0, 7) * wl10[0][1][l][k] +
							getLayer(l5, i0, j2, l - 256, 0, 7) * wl10[0][2][l][k] +
							getLayer(l5, i0, j3, l - 256, 0, 7) * wl10[0][3][l][k] +
							getLayer(l5, i1, j0, l - 256, 0, 7) * wl10[1][0][l][k] +
							getLayer(l5, i1, j1, l - 256, 0, 7) * wl10[1][1][l][k] +
							getLayer(l5, i1, j2, l - 256, 0, 7) * wl10[1][2][l][k] +
							getLayer(l5, i1, j3, l - 256, 0, 7) * wl10[1][3][l][k] +
							getLayer(l5, i2, j0, l - 256, 0, 7) * wl10[2][0][l][k] +
							getLayer(l5, i2, j1, l - 256, 0, 7) * wl10[2][1][l][k] +
							getLayer(l5, i2, j2, l - 256, 0, 7) * wl10[2][2][l][k] +
							getLayer(l5, i2, j3, l - 256, 0, 7) * wl10[2][3][l][k] +
							getLayer(l5, i3, j0, l - 256, 0, 7) * wl10[3][0][l][k] +
							getLayer(l5, i3, j1, l - 256, 0, 7) * wl10[3][1][l][k] +
							getLayer(l5, i3, j2, l - 256, 0, 7) * wl10[3][2][l][k] +
							getLayer(l5, i3, j3, l - 256, 0, 7) * wl10[3][3][l][k];
					}

					l10[i][j][k] += bl10[k]; // bias
					l10[i][j][k] = relu(l10[i][j][k]); // activation
				}
			}
		}

		// L10 layer normalization, activation
		float rmeanl10[256] = { 0.0f };
		float rvarl10[256] = { 0.0f };
		for (int k = 0; k < 256; k++) {

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					rmeanl10[k] += l10[i][j][k];
				}
			}
			rmeanl10[k] /= 256.0f; // 16 * 16

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					rvarl10[k] += powf(l10[i][j][k] - rmeanl10[k], 2);
				}
			}
			rvarl10[k] /= 256.0f; // 16 * 16

			for (int i = 0; i < 16; i++) {
				for (int j = 0; j < 16; j++) {
					// normalization
					l10[i][j][k] = batchNorm(l10[i][j][k], nl10[0][k], nl10[1][k],
						rmeanl10[k], rvarl10[k]);
				}
			}
		}

		cout << "L10 done" << endl;

		// L11, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 128; k++) {
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {

					l11[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 256; l++) {
						l11[i][j][k] +=
							getLayer(l10, i0, j0, l, 0, 15) * wl11[0][0][l][k] +
							getLayer(l10, i0, j1, l, 0, 15) * wl11[0][1][l][k] +
							getLayer(l10, i0, j2, l, 0, 15) * wl11[0][2][l][k] +
							getLayer(l10, i0, j3, l, 0, 15) * wl11[0][3][l][k] +
							getLayer(l10, i1, j0, l, 0, 15) * wl11[1][0][l][k] +
							getLayer(l10, i1, j1, l, 0, 15) * wl11[1][1][l][k] +
							getLayer(l10, i1, j2, l, 0, 15) * wl11[1][2][l][k] +
							getLayer(l10, i1, j3, l, 0, 15) * wl11[1][3][l][k] +
							getLayer(l10, i2, j0, l, 0, 15) * wl11[2][0][l][k] +
							getLayer(l10, i2, j1, l, 0, 15) * wl11[2][1][l][k] +
							getLayer(l10, i2, j2, l, 0, 15) * wl11[2][2][l][k] +
							getLayer(l10, i2, j3, l, 0, 15) * wl11[2][3][l][k] +
							getLayer(l10, i3, j0, l, 0, 15) * wl11[3][0][l][k] +
							getLayer(l10, i3, j1, l, 0, 15) * wl11[3][1][l][k] +
							getLayer(l10, i3, j2, l, 0, 15) * wl11[3][2][l][k] +
							getLayer(l10, i3, j3, l, 0, 15) * wl11[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 256; l < 512; l++) {
						l11[i][j][k] +=
							getLayer(l4, i0, j0, l - 256, 0, 15) * wl11[0][0][l][k] +
							getLayer(l4, i0, j1, l - 256, 0, 15) * wl11[0][1][l][k] +
							getLayer(l4, i0, j2, l - 256, 0, 15) * wl11[0][2][l][k] +
							getLayer(l4, i0, j3, l - 256, 0, 15) * wl11[0][3][l][k] +
							getLayer(l4, i1, j0, l - 256, 0, 15) * wl11[1][0][l][k] +
							getLayer(l4, i1, j1, l - 256, 0, 15) * wl11[1][1][l][k] +
							getLayer(l4, i1, j2, l - 256, 0, 15) * wl11[1][2][l][k] +
							getLayer(l4, i1, j3, l - 256, 0, 15) * wl11[1][3][l][k] +
							getLayer(l4, i2, j0, l - 256, 0, 15) * wl11[2][0][l][k] +
							getLayer(l4, i2, j1, l - 256, 0, 15) * wl11[2][1][l][k] +
							getLayer(l4, i2, j2, l - 256, 0, 15) * wl11[2][2][l][k] +
							getLayer(l4, i2, j3, l - 256, 0, 15) * wl11[2][3][l][k] +
							getLayer(l4, i3, j0, l - 256, 0, 15) * wl11[3][0][l][k] +
							getLayer(l4, i3, j1, l - 256, 0, 15) * wl11[3][1][l][k] +
							getLayer(l4, i3, j2, l - 256, 0, 15) * wl11[3][2][l][k] +
							getLayer(l4, i3, j3, l - 256, 0, 15) * wl11[3][3][l][k];
					}

					l11[i][j][k] += bl11[k]; // bias
					l11[i][j][k] = relu(l11[i][j][k]); // activation
				}
			}
		}

		// L11 layer normalization, activation
		float rmeanl11[128] = { 0.0f };
		float rvarl11[128] = { 0.0f };
		for (int k = 0; k < 128; k++) {

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					rmeanl11[k] += l11[i][j][k];
				}
			}
			rmeanl11[k] /= 1024.0f; // 32 * 32

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					rvarl11[k] += powf(l11[i][j][k] - rmeanl11[k], 2);
				}
			}
			rvarl11[k] /= 1024.0f; // 32 * 32

			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					// normalization
					l11[i][j][k] = batchNorm(l11[i][j][k], nl11[0][k], nl11[1][k],
						rmeanl11[k], rvarl11[k]);
				}
			}
		}

		cout << "L11 done" << endl;

		// L12, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 64; k++) {
			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {

					l12[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 128; l++) {
						l12[i][j][k] +=
							getLayer(l11, i0, j0, l, 0, 31) * wl12[0][0][l][k] +
							getLayer(l11, i0, j1, l, 0, 31) * wl12[0][1][l][k] +
							getLayer(l11, i0, j2, l, 0, 31) * wl12[0][2][l][k] +
							getLayer(l11, i0, j3, l, 0, 31) * wl12[0][3][l][k] +
							getLayer(l11, i1, j0, l, 0, 31) * wl12[1][0][l][k] +
							getLayer(l11, i1, j1, l, 0, 31) * wl12[1][1][l][k] +
							getLayer(l11, i1, j2, l, 0, 31) * wl12[1][2][l][k] +
							getLayer(l11, i1, j3, l, 0, 31) * wl12[1][3][l][k] +
							getLayer(l11, i2, j0, l, 0, 31) * wl12[2][0][l][k] +
							getLayer(l11, i2, j1, l, 0, 31) * wl12[2][1][l][k] +
							getLayer(l11, i2, j2, l, 0, 31) * wl12[2][2][l][k] +
							getLayer(l11, i2, j3, l, 0, 31) * wl12[2][3][l][k] +
							getLayer(l11, i3, j0, l, 0, 31) * wl12[3][0][l][k] +
							getLayer(l11, i3, j1, l, 0, 31) * wl12[3][1][l][k] +
							getLayer(l11, i3, j2, l, 0, 31) * wl12[3][2][l][k] +
							getLayer(l11, i3, j3, l, 0, 31) * wl12[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 128; l < 256; l++) {
						l12[i][j][k] +=
							getLayer(l3, i0, j0, l - 128, 0, 31) * wl12[0][0][l][k] +
							getLayer(l3, i0, j1, l - 128, 0, 31) * wl12[0][1][l][k] +
							getLayer(l3, i0, j2, l - 128, 0, 31) * wl12[0][2][l][k] +
							getLayer(l3, i0, j3, l - 128, 0, 31) * wl12[0][3][l][k] +
							getLayer(l3, i1, j0, l - 128, 0, 31) * wl12[1][0][l][k] +
							getLayer(l3, i1, j1, l - 128, 0, 31) * wl12[1][1][l][k] +
							getLayer(l3, i1, j2, l - 128, 0, 31) * wl12[1][2][l][k] +
							getLayer(l3, i1, j3, l - 128, 0, 31) * wl12[1][3][l][k] +
							getLayer(l3, i2, j0, l - 128, 0, 31) * wl12[2][0][l][k] +
							getLayer(l3, i2, j1, l - 128, 0, 31) * wl12[2][1][l][k] +
							getLayer(l3, i2, j2, l - 128, 0, 31) * wl12[2][2][l][k] +
							getLayer(l3, i2, j3, l - 128, 0, 31) * wl12[2][3][l][k] +
							getLayer(l3, i3, j0, l - 128, 0, 31) * wl12[3][0][l][k] +
							getLayer(l3, i3, j1, l - 128, 0, 31) * wl12[3][1][l][k] +
							getLayer(l3, i3, j2, l - 128, 0, 31) * wl12[3][2][l][k] +
							getLayer(l3, i3, j3, l - 128, 0, 31) * wl12[3][3][l][k];
					}

					l12[i][j][k] += bl12[k]; // bias
					l12[i][j][k] = relu(l12[i][j][k]); // activation
				}
			}
		}

		// L12 layer normalization, activation
		float rmeanl12[64] = { 0.0f };
		float rvarl12[64] = { 0.0f };
		for (int k = 0; k < 64; k++) {

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					rmeanl12[k] += l12[i][j][k];
				}
			}
			rmeanl12[k] /= 4096.0f; // 64 * 64

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					rvarl12[k] += powf(l12[i][j][k] - rmeanl12[k], 2);
				}
			}
			rvarl12[k] /= 4096.0f; // 64 * 64

			for (int i = 0; i < 64; i++) {
				for (int j = 0; j < 64; j++) {
					// normalization
					l12[i][j][k] = batchNorm(l12[i][j][k], nl12[0][k], nl12[1][k],
						rmeanl12[k], rvarl12[k]);
				}
			}
		}

		cout << "L12 done" << endl;

		// L13, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 64; k++) {
			for (int i = 0; i < 128; i++) {
				for (int j = 0; j < 128; j++) {

					l13[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 64; l++) {
						l13[i][j][k] +=
							getLayer(l12, i0, j0, l, 0, 63) * wl13[0][0][l][k] +
							getLayer(l12, i0, j1, l, 0, 63) * wl13[0][1][l][k] +
							getLayer(l12, i0, j2, l, 0, 63) * wl13[0][2][l][k] +
							getLayer(l12, i0, j3, l, 0, 63) * wl13[0][3][l][k] +
							getLayer(l12, i1, j0, l, 0, 63) * wl13[1][0][l][k] +
							getLayer(l12, i1, j1, l, 0, 63) * wl13[1][1][l][k] +
							getLayer(l12, i1, j2, l, 0, 63) * wl13[1][2][l][k] +
							getLayer(l12, i1, j3, l, 0, 63) * wl13[1][3][l][k] +
							getLayer(l12, i2, j0, l, 0, 63) * wl13[2][0][l][k] +
							getLayer(l12, i2, j1, l, 0, 63) * wl13[2][1][l][k] +
							getLayer(l12, i2, j2, l, 0, 63) * wl13[2][2][l][k] +
							getLayer(l12, i2, j3, l, 0, 63) * wl13[2][3][l][k] +
							getLayer(l12, i3, j0, l, 0, 63) * wl13[3][0][l][k] +
							getLayer(l12, i3, j1, l, 0, 63) * wl13[3][1][l][k] +
							getLayer(l12, i3, j2, l, 0, 63) * wl13[3][2][l][k] +
							getLayer(l12, i3, j3, l, 0, 63) * wl13[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 64; l < 128; l++) {
						l13[i][j][k] +=
							getLayer(l2, i0, j0, l - 64, 0, 63) * wl13[0][0][l][k] +
							getLayer(l2, i0, j1, l - 64, 0, 63) * wl13[0][1][l][k] +
							getLayer(l2, i0, j2, l - 64, 0, 63) * wl13[0][2][l][k] +
							getLayer(l2, i0, j3, l - 64, 0, 63) * wl13[0][3][l][k] +
							getLayer(l2, i1, j0, l - 64, 0, 63) * wl13[1][0][l][k] +
							getLayer(l2, i1, j1, l - 64, 0, 63) * wl13[1][1][l][k] +
							getLayer(l2, i1, j2, l - 64, 0, 63) * wl13[1][2][l][k] +
							getLayer(l2, i1, j3, l - 64, 0, 63) * wl13[1][3][l][k] +
							getLayer(l2, i2, j0, l - 64, 0, 63) * wl13[2][0][l][k] +
							getLayer(l2, i2, j1, l - 64, 0, 63) * wl13[2][1][l][k] +
							getLayer(l2, i2, j2, l - 64, 0, 63) * wl13[2][2][l][k] +
							getLayer(l2, i2, j3, l - 64, 0, 63) * wl13[2][3][l][k] +
							getLayer(l2, i3, j0, l - 64, 0, 63) * wl13[3][0][l][k] +
							getLayer(l2, i3, j1, l - 64, 0, 63) * wl13[3][1][l][k] +
							getLayer(l2, i3, j2, l - 64, 0, 63) * wl13[3][2][l][k] +
							getLayer(l2, i3, j3, l - 64, 0, 63) * wl13[3][3][l][k];
					}

					l13[i][j][k] += bl13[k]; // bias
					l13[i][j][k] = relu(l13[i][j][k]); // activation
				}
			}
		}

		// L13 layer normalization, activation
		float rmeanl13[64] = { 0.0f };
		float rvarl13[64] = { 0.0f };
		for (int k = 0; k < 64; k++) {

			for (int i = 0; i < 128; i++) {
				for (int j = 0; j < 128; j++) {
					rmeanl13[k] += l13[i][j][k];
				}
			}
			rmeanl13[k] /= 16384.0f; // 128 * 128

			for (int i = 0; i < 128; i++) {
				for (int j = 0; j < 128; j++) {
					rvarl13[k] += powf(l13[i][j][k] - rmeanl13[k], 2);
				}
			}
			rvarl13[k] /= 16384.0f; // 128 * 128

			for (int i = 0; i < 128; i++) {
				for (int j = 0; j < 128; j++) {
					// normalization
					l13[i][j][k] = batchNorm(l13[i][j][k], nl13[0][k], nl13[1][k],
						rmeanl13[k], rvarl13[k]);
				}
			}
		}

		cout << "L13 done" << endl;

		// L14, kernel=4x4, stride=1, padding=1,2
		for (int k = 0; k < 3; k++) {
			for (int i = 0; i < 256; i++) {
				for (int j = 0; j < 256; j++) {

					l14[i][j][k] = 0.0f;
					int i1 = i, i0 = i1 - 1, i2 = i1 + 1, i3 = i1 + 2;
					int j1 = j, j0 = j1 - 1, j2 = j1 + 1, j3 = j1 + 2;

					// Nearest neighbor upscaling
					i0 = int(floorf(i0 * 0.5f));
					i1 = int(floorf(i1 * 0.5f));
					i2 = int(floorf(i2 * 0.5f));
					i3 = int(floorf(i3 * 0.5f));
					j0 = int(floorf(j0 * 0.5f));
					j1 = int(floorf(j1 * 0.5f));
					j2 = int(floorf(j2 * 0.5f));
					j3 = int(floorf(j3 * 0.5f));

					for (int l = 0; l < 64; l++) {
						l14[i][j][k] +=
							getLayer(l13, i0, j0, l, 0, 127) * wl14[0][0][l][k] +
							getLayer(l13, i0, j1, l, 0, 127) * wl14[0][1][l][k] +
							getLayer(l13, i0, j2, l, 0, 127) * wl14[0][2][l][k] +
							getLayer(l13, i0, j3, l, 0, 127) * wl14[0][3][l][k] +
							getLayer(l13, i1, j0, l, 0, 127) * wl14[1][0][l][k] +
							getLayer(l13, i1, j1, l, 0, 127) * wl14[1][1][l][k] +
							getLayer(l13, i1, j2, l, 0, 127) * wl14[1][2][l][k] +
							getLayer(l13, i1, j3, l, 0, 127) * wl14[1][3][l][k] +
							getLayer(l13, i2, j0, l, 0, 127) * wl14[2][0][l][k] +
							getLayer(l13, i2, j1, l, 0, 127) * wl14[2][1][l][k] +
							getLayer(l13, i2, j2, l, 0, 127) * wl14[2][2][l][k] +
							getLayer(l13, i2, j3, l, 0, 127) * wl14[2][3][l][k] +
							getLayer(l13, i3, j0, l, 0, 127) * wl14[3][0][l][k] +
							getLayer(l13, i3, j1, l, 0, 127) * wl14[3][1][l][k] +
							getLayer(l13, i3, j2, l, 0, 127) * wl14[3][2][l][k] +
							getLayer(l13, i3, j3, l, 0, 127) * wl14[3][3][l][k];
					}

					// Concat, skip in a previous layer
					for (int l = 64; l < 128; l++) {
						l14[i][j][k] +=
							getLayer(l1, i0, j0, l - 64, 0, 127) * wl14[0][0][l][k] +
							getLayer(l1, i0, j1, l - 64, 0, 127) * wl14[0][1][l][k] +
							getLayer(l1, i0, j2, l - 64, 0, 127) * wl14[0][2][l][k] +
							getLayer(l1, i0, j3, l - 64, 0, 127) * wl14[0][3][l][k] +
							getLayer(l1, i1, j0, l - 64, 0, 127) * wl14[1][0][l][k] +
							getLayer(l1, i1, j1, l - 64, 0, 127) * wl14[1][1][l][k] +
							getLayer(l1, i1, j2, l - 64, 0, 127) * wl14[1][2][l][k] +
							getLayer(l1, i1, j3, l - 64, 0, 127) * wl14[1][3][l][k] +
							getLayer(l1, i2, j0, l - 64, 0, 127) * wl14[2][0][l][k] +
							getLayer(l1, i2, j1, l - 64, 0, 127) * wl14[2][1][l][k] +
							getLayer(l1, i2, j2, l - 64, 0, 127) * wl14[2][2][l][k] +
							getLayer(l1, i2, j3, l - 64, 0, 127) * wl14[2][3][l][k] +
							getLayer(l1, i3, j0, l - 64, 0, 127) * wl14[3][0][l][k] +
							getLayer(l1, i3, j1, l - 64, 0, 127) * wl14[3][1][l][k] +
							getLayer(l1, i3, j2, l - 64, 0, 127) * wl14[3][2][l][k] +
							getLayer(l1, i3, j3, l - 64, 0, 127) * wl14[3][3][l][k];
					}

					l14[i][j][k] += bl14[k]; // bias
					l14[i][j][k] = tanhf(l14[i][j][k]); // activation
				}
			}
		}
		cout << "L14 done" << endl;

		for (int k = 0; k < 3; k++) {
			for (int i = 0; i < 256; i++) {
				for (int j = 0; j < 256; j++) {
					imageOut[i][j][k] = (l14[i][j][k]);
				}
			}
		}
	}
};

#define PATH "C:\\Users\\Alan\\source\\repos\\pix2pixPython\\pikachu.bin"

int main() {
	
	Mat img;
	img = imread("C:\\Users\\Alan\\source\\repos\\pix2pixPython\\input1.jpg");

	float*** imgIn = (float***)pix2pix::createArray(256, 256, 3, sizeof(float));
	float*** imgOut = (float***)pix2pix::createArray(256, 256, 3, sizeof(float));

	for (int k = 0; k < 3; k++) {
		for (int i = 0; i < 256; i++) {
			for (int j = 0; j < 256; j++) {
				imgIn[i][j][k] = (img.at<Vec3b>(i, j)[2 - k] - 127.5f) / 127.5f;
			}
		}
	}

	//for (int k = 0; k < 3; k++) {
	//	for (int i = 0; i < 256; i++) {
	//		for (int j = 0; j < 256; j++) {
	//			if (k == 0) imgIn[i][j][k] = (i / 255.0) * (j / 255.0) * 2.0 - 1.0;
	//			else if (k == 1) imgIn[i][j][k] = ((255.0 - i) / 255.0) * (j / 255.0) * 2.0 - 1.0;
	//			else imgIn[i][j][k] = (i / 255.0) * ((255.0 - j) / 255.0) * 2.0 - 1.0;
	//		}
	//	}
	//}

	pix2pix p2pObj = pix2pix(PATH);
	p2pObj.forwardProp(imgIn, imgOut);

	Mat outMat(256, 256, CV_8UC3);

	for (int k = 0; k < 3; k++) {
		for (int i = 0; i < 256; i++) {
			for (int j = 0; j < 256; j++) {
				outMat.at<Vec3b>(i, j)[2 - k] = imgOut[i][j][k] * 127.5f + 127.5f;
			}
		}
	}

	namedWindow("Display window", WINDOW_NORMAL); // Create a window for display.
	resizeWindow("Display window", 256, 256);
	imshow("Display window", outMat);                // Show our image inside it.
	waitKey(0);

	pix2pix::freeArray(256, 256, 3, (void***)imgIn);
	pix2pix::freeArray(256, 256, 3, (void***)imgOut);

	return 0;
}