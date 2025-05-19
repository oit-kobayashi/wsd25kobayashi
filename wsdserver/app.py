from flask import Flask, request, jsonify, abort
from flask_cors import CORS
import nanoid
import cv2
app = Flask(__name__)
CORS(app) 

@app.route('/', methods=['GET', 'POST'])
def root():
    return '<h1>hello, world</h1>'

@app.route('/greet/<name>')
def greet(name):
    return f'hello, {name}!'

@app.route('/v1/photos', methods=['POST'])
def post_photos():
    file = request.files['file']
    if file.content_type == 'image/jpeg':
        filename = f'{nanoid.generate(size=4)}.jpg'
        file.save(f'static/{filename}')
        img0 = cv2.imread(f'static/{filename}', cv2.IMREAD_GRAYSCALE)
        img1 = cv2.Canny(img0, 100, 200)
        cv2.imwrite(f'static/{filename}', img1)
        
        resp = {'url': f'/static/{filename}'}
        return jsonify(resp)
    else:
        abort(400)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
