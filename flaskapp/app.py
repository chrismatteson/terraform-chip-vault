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
import boto3

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
    result={}
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
    context = {}
    text=request.form['text']
    command=request.form['command']
    run_command = "./vaulthook.sh {} {}".format(command, text)
    try:
      result = subprocess.check_output(
        [run_command], shell=True)
    except subprocess.CalledProcessError as e:
      return "An error occurred while trying to fetch task status updates."
    stringdata=json.dumps({ "command": command, "text": result.decode("utf-8") })
    context=json.loads(stringdata)
    return render_template('transit.html', **context)

@app.route('/s3bucket/')
def s3bucket():
    """ s3 Bucket Dynamic Secerts.
    """
    context = {'active_services' : config.active_services,
               'img_width'  : config.img_width,
               'img_height' : config.img_height,
              }
    return render_template('s3bucket.html', **context)

@app.route('/s3bucket/', methods=['POST'])
def s3bucket_post():
    """ s3 Bucket Dynamic Secerts.
    """
    creds_file='awscreds.json'
    try:
        with app.open_resource(creds_file, 'r') as IF:
            creds=json.load(IF)
            client = boto3.client(
                's3',
                aws_access_key_id=creds['ACCESS_KEY'],
                aws_secret_access_key=creds['SECRET_KEY'],
#                aws_session_token=creds['SESSION_TOKEN'],
            )
    except Exception as e:
        print(e)
    bucket=request.form['bucket']
    key=request.form['key']
    command=request.form['command']
    if command == 'ls':
        print('Command is ls')
        response=client.list_objects(
            Bucket=bucket
	)
        contents={key:response[key] for key in ['Contents']}
        stringdata=json.dumps({ 'bucket': bucket, 'files': str(contents) })
        context=json.loads(stringdata)
    elif command == 'get':
        print('Command is get')
        response = client.generate_presigned_url('get_object',
            Params={
                'Bucket': bucket,
                'Key': key},
            ExpiresIn='60')
        stringdata=json.dumps({ 'bucket': bucket, 'files': response })
        context=json.loads(stringdata)
    elif command == 'rm':
        print('Command is rm')
        response = client.delete_object(
    		Bucket='string',
    		Key='string')
        stringdata=json.dumps({ 'bucket': bucket, 'files': 'deleted' })
        context=json.loads(stringdata)
    else:
        print('Command is not supported')

    return render_template('s3bucket.html', **context)


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
