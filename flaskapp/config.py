import os

# Configuration defaults for all settings for this application

DOGS_UPSTREAM    = 'http://127.0.0.1:42100'
CATS_UPSTREAM    = 'http://127.0.0.1:42200'
PARROTS_UPSTREAM = 'http://127.0.0.1:42300'
RABBITS_UPSTREAM = 'http://127.0.0.1:42400'
ACTIVE_SERVICES  = "Dogs, Cats, Rabbits"
IMG_WIDTH = 200
IMG_HEIGHT = 200

img_width  = os.environ.get('IMG_WIDTH', IMG_WIDTH)
img_height = os.environ.get('IMG_HEIGHT', IMG_HEIGHT)

service = {
    'Dogs'    : {'upstream' : os.environ.get('DOGS_UPSTREAM', DOGS_UPSTREAM)},
    'Cats'    : {'upstream' : os.environ.get('CATS_UPSTREAM', CATS_UPSTREAM)},
    'Parrots' : {'upstream' : os.environ.get('PARROTS_UPSTREAM', PARROTS_UPSTREAM)},
    'Rabbits' : {'upstream' : os.environ.get('RABBITS_UPSTREAM', RABBITS_UPSTREAM)},
}
 
# Make services dynamic by choice
active_services = [ i.strip() for i in os.environ.get('ACTIVE_SERVICES', ACTIVE_SERVICES).split(',')]
