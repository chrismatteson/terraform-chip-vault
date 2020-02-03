import os
import glob
import random
from flask import Flask
from flask import render_template, send_file, current_app, request
import json
import requests
import config
import io
import pandas as pd
import pymysql
import subprocess

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
            db = pymysql.connect(context['hostname'],context['username'],context['password'] )
            cursor = db.cursor()
            cursor.execute("select user, authentication_string, host from mysql.user;")
            data = [dict((cursor.description[i][0], value) \
                for i, value in enumerate(row)) for row in cursor.fetchall()]
            print(data)
            stringdata=json.dumps({"mysqlusertable": data })
            jsondata=json.loads(stringdata)
            result={**context,**jsondata}
            cursor.close()
    except Exception as e:
        print(e)
    return render_template('consul-template.html', **result)


@app.route('/transit/')
def transit():
    """ Transit Encryption.
    """
    context = {'active_services' : config.active_services,
               'img_width'  : config.img_width,
               'img_height' : config.img_height,
              }
    return render_template('transit.html', **context)

@app.route('/transit/', methods=['POST'])
def transit_post():
    """ Transit Encryption.
    """
    context = {'active_services' : config.active_services,
               'img_width'  : config.img_width,
               'img_height' : config.img_height,
              }
    bucket=request.form['bucket']
    key=request.form['key']
    command=request.form['command']
    if command = 'ls':
        print('Command is ls')
        my_bucket = s3.Bucket(bucket)
        files = []
        for file in my_bucket.objects.all():
            files.append(file.key)
    elif command = 'get':
        print('Command is get')
    elif command = 'rm':
        print('Command is rm')
    else:
        print('Command is not supported')
    run_command = "./vaulthook.sh {} {}".format(command, text)
    try:
      result = subprocess.check_output(
        [run_command], shell=True)
    except subprocess.CalledProcessError as e:
      return "An error occurred while trying to fetch task status updates."
    return result

@app.route('/s3bucket/')
def s3bucket():
    """ s3 Bucket Dynamic Secerts.
    """
    

    return render_template('s3bucket.html')


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
