import struct
from keras.models import load_model

dest = 'tree.bytes'
model = load_model('./tree/model_074400.h5')
weights = model.get_weights()

# Make the output easier to parse in HLSL by making the dims a multiple of 4
def write_output(array):
    with open(dest, 'ab') as f:
        for i in range(0, len(array)):
            for j in range(0, len(array[0])):
                for k in range(0, len(array[0][0])):
                    for l in range(0, 4):
                        if (l == 3):
                            f.write(struct.pack('f', 0.0))
                        else:
                            f.write(struct.pack('f', array[i][j][k][l]))

def write_weights(array, mode='ab'):
    with open(dest, mode) as f:
        for i in range(0, len(array)):
            for j in range(0, len(array[0])):
                for k in range(0, len(array[0][0])):
                    for l in range(0, len(array[0][0][0])):
                        f.write(struct.pack('f', array[i][j][k][l]))
        f.close()
        
def write_bias(array):
    with open(dest, 'ab') as f:
        for i in range(0, len(array)):
            f.write(struct.pack('f', array[i]))
        f.close()
        
def write_norm(array):
    with open(dest, 'ab') as f:
        for i in range(0, len(array)):
            f.write(struct.pack('f', array[i]))
        f.close()
        
if 1:
    # L1
    write_weights(weights[0], 'wb')
    write_bias(weights[1])
    
    # L2 to L13
    for l in range(0, 12):
        write_weights(weights[l * 6 + 2])
        write_bias(weights[l * 6 + 3])
        for i in range(0, 4):
            write_norm(weights[l * 6 + 4 + i])
            
    # L14
    write_output(weights[74])
    write_bias(weights[75])
else:
    # Small network
    # L1
    write_weights(weights[0], 'wb')
    write_bias(weights[1])
    
    # L2 to L13
    for l in range(0, 4):
        write_weights(weights[l * 6 + 2])
        write_bias(weights[l * 6 + 3])
        for i in range(0, 4):
            write_norm(weights[l * 6 + 4 + i])
            
    # L14
    write_weights(weights[26])
    write_bias(weights[27])
