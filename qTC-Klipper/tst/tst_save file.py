# import the requests and PIL modules
import requests
# from PIL import Image
from PIL import Image
import cv2
import numpy as np

# define the URL of the MJPG stream
stream_url = "http://192.168.1.204//webcam2/stream"

# define the name of the output file
output_file = "frame.jpg"

# # create a requests session object
session = requests.Session()

# # send a GET request to the stream URL
# response = session.get(stream_url, stream=True)

# # check if the response is OK
# if response.status_code == 200:

with session.get(stream_url, stream=True) as stream:
    if stream.ok:
        chunk_size = 1024
        bytes_ = b''
        for chunk in stream.iter_content(chunk_size=chunk_size):
            bytes_ += chunk
            a = bytes_.find(b'\xff\xd8')
            b = bytes_.find(b'\xff\xd9')
            if a != -1 and b != -1:
                jpg = bytes_[a:b+2]
                jpeg_data = cv2.imdecode(np.frombuffer(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)
                break

    # convert collor space from BGR to RGB
    jpeg_data2 = cv2.cvtColor(jpeg_data, cv2.COLOR_BGR2RGB)

    # create a PIL image object from the JPEG data
    image = Image.fromarray(jpeg_data2)
    # save the image to the output file
    image.save(output_file)
    # print a success message
    print(f"Saved one frame from {stream_url} to {output_file}")
