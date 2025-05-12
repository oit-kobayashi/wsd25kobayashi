from flask import Flask, request, jsonify, abort
import nanoid
app = Flask(__name__)
 

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
        resp = {'url': f'/static/{filename}'}
        return jsonify(resp)
    else:
        abort(400)


if __name__ == '__main__':
    app.run()
