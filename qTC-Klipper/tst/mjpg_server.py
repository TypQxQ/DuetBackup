# import the Flask module, the MJPEGResponse class, and the os module
import datetime, io, time, copy
from flask import Flask
from mjpeg.server import MJPEGResponse
import os
from flask import send_from_directory, send_file
from PIL import Image, ImageDraw, ImageFont, ImageFile

# create a Flask app
app = Flask(__name__)

# define the name of the JPEG file
jpeg_file = "frame.jpg"
jpeg_file2 = "frame2.jpg"


last_frame = None
last_modified_time = None

def get_image():
    global last_modified_time
    # get the current modified time of the file
    current_modified = os.path.getmtime(jpeg_file)

    # Parse the date to a string
    date_str =datetime.datetime.fromtimestamp(current_modified, tz=datetime.timezone.utc).strftime("%a %b %d %H:%M:%S %Y")

    # if the file has changed, yield the new file as bytes
    if current_modified != last_modified_time:
        # So the app doesn't crash if the image is truncated
        ImageFile.LOAD_TRUNCATED_IMAGES = True
        # open the file in binary mode
        image = Image.open(jpeg_file)
        # read the file content as bytes
        image.load()

        global last_frame
        last_frame = image

    # Draw the text on the image
    changedImage = drawOnFrame(last_frame, date_str )

    # Save the image to a byte array
    jpeg_bytedata = io.BytesIO()
    changedImage.save(jpeg_bytedata, format='JPEG')

    # update the last modified time
    last_modified_time = current_modified
    
    return jpeg_bytedata.getvalue()


# define a generator function that yields the JPEG file
def generate_frame():
    yield get_image()


# define a generator function that yields the JPEG file
def generate_frame5():
    # use a variable to store the last modified time of the file
    
    q = 0
    qq = 0
    # use an infinite loop to check the file
    while True:
        # get the current modified time of the file
        current_modified = os.path.getmtime(jpeg_file)

        # Parse the date to a string
        date_str =datetime.datetime.fromtimestamp(current_modified, tz=datetime.timezone.utc).strftime("%a %b %d %H:%M:%S %Y")

        # if the file has changed, yield the new file as bytes
        if current_modified != last_modified_time:
            # increase the counter
            q = q + 1

            # So the app doesn't crash if the image is truncated
            ImageFile.LOAD_TRUNCATED_IMAGES = True
            # open the file in binary mode
            image = Image.open(jpeg_file)
            # read the file content as bytes
            image.load()

            
            # Draw the text on the image
            changedImage = drawOnFrame(image, date_str + " - " + str(q) + " - " + str(qq))

            # Save the image to a byte array
            jpeg_bytedata = io.BytesIO()
            changedImage.save(jpeg_bytedata, format='JPEG')

            # update the last modified time
            last_modified_time = current_modified
            
            global last_frame
            last_frame = image
            
            
            # yield the bytes object
            yield jpeg_bytedata.getvalue()
            
        # elif last_frame_time < datetime.datetime.now() + datetime.timedelta(seconds=0.25):
        else:
            # increase the counter
            qq = qq + 1

            textToWrite = date_str + " - " + str(q) + " - " + str(qq)
            changedImage = drawOnFrame(last_frame, textToWrite)
            
            # Save the image to a byte array
            jpeg_bytedata = io.BytesIO()
            changedImage.save(jpeg_bytedata, format='JPEG')

            # yield the bytes object
            yield jpeg_bytedata.getvalue()

        time.sleep(0.25)


def drawOnFrame(image, text):
    usedFrame = copy.deepcopy(image)
    
    # Create a draw object
    draw = ImageDraw.Draw(usedFrame)

    # Choose a font
    font = ImageFont.truetype("arial.ttf", 32)
    
    
    # date_str = datetime.datetime.strftime(current_modified, "%a %b %d %H:%M:%S %Y")
    
    # Draw the date on the image
    draw.text((10, 10), text, font=font, fill=(255, 255, 255))

    return usedFrame


@app.route('/static')
def send_static():
    if last_frame is None:
        return
    else:
        yield get_image()
        return
        textToWrite = "static"
        changedImage = drawOnFrame(last_frame, textToWrite)
        
        
        # Save the image to a byte array
        jpeg_bytedata = io.BytesIO()
        changedImage.save(jpeg_bytedata, format='JPEG')

        # yield the bytes object
        yield jpeg_bytedata.getvalue()

#         # return last_frame.getvalue()

#     return send_file(os.path.abspath(jpeg_file))
#     # define a global variable
#     global_var = 0

#     # define a function that modifies the global variable
#     def modify_global_var():
#         global global_var
#         global_var += 1

#     # call the function multiple times
#     modify_global_var()
#     modify_global_var()
#     modify_global_var()

#     # print the value of the global variable
#     print(global_var) # output: 3
# # send_from_directory( os.path.expanduser('~'), jpeg_file, cache_timeout=0)
 

# define a route that returns a MJPEG response
@app.route("/stream")
def stream():
    # create a MJPEG response object with the generator function
    response = MJPEGResponse(generate_frame())
    # return the response object
    return response

# run the app
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8088)
    last_frame = None