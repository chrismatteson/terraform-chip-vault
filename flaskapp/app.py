import os
import glob
import random
from flask import Flask
from flask import render_template, send_file, current_app
import json
import requests
import config
import io
import pandas as pd
import pymysql

# Be the main frame for all applications
# Loads static page into one tab
# Loads dynamic page into the second tab
# Dynamic page requests picture data from the picture-service app

BIND_HOST='0.0.0.0'
BIND_PORT=8000

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root'
app.config['MYSQL_DB'] = 'MyDB'

mysql = MySQL(app)

@app.route('/healthz')
def healthz():
    return 'OK'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/consul-template/')
def consul_template():
    context={}
    context_file='mysqldbcreds.json'
    try:
        with app.open_resource(context_file, 'r') as IF:
            context=json.load(IF)
        cur = mysql.connection.cursor()
        cur.execute("SELECT CURRENT_USER()")
        mysql.connection.commit()
        data = cursor.fetchone()
        context=json.oad(data)
        cur.close()
    except Exception as e:
        print("JSON Input file {} missing".format(context_file))
        print(e)
    return render_template('consul-template.html', **context)


@app.route('/transit/')
def transit():
    """ Transit Encryption.
    """
    context = {'active_services' : config.active_services,
               'img_width'  : config.img_width,
               'img_height' : config.img_height,
              }
    return render_template('transit.html', **context)

@app.route('/s3bucket/')
def s3bucket():
    return render_template('s3bucket.html')

@app.route('/img/<service>')
def get_image(service):
    """Proxy for returning an image via a backend service.   
    Image source for Connect proxies returns a localhost which will
    cause the browser to try to retrieve locally."""
    address = config.service[service]['upstream']
    response = requests.get(address) 
    image = io.BytesIO(response.content)
    mimetype = response.headers['Content-Type']
    return send_file(image, mimetype=mimetype, cache_timeout=-1)


class Upstream:
    def __init__(self, service, address):
        """ Service is the name of the upstream service name.
        Address should be the connection string containing protocol, ip, port of the local upstream connection
        e.g. http://127.0.0.1:10000. 
        """
        self.address = address
        self.service = service

if __name__ == '__main__':
    host = os.environ.get('BIND_HOST', BIND_HOST)
    port = os.environ.get('BIND_PORT', BIND_PORT)
    app.run(host=host, port=port)
