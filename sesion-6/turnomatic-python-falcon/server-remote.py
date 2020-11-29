import falcon
import json
import redis

REDIS_HOST = 'service.pinchito.es'
REDIS_PORT = 7079
REDIS_DB = 0

class TurnomaticResource():

    def __init__(self, cache):
        self.cache = cache

    def on_get(self, req, resp, id):
        """Handles GET requests"""
        resp.status = falcon.HTTP_200
        resp.set_header('Content-Type', 'application/json')
        
        resp.body = json.dumps({
            'id': id,
            'turno': self.cache.incr(id)
        })
        

def create_app():
    app = falcon.API()

    cache = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0)

    turnomatic = TurnomaticResource(cache)
    app.add_route('/turno/{id}', turnomatic)

    return app
