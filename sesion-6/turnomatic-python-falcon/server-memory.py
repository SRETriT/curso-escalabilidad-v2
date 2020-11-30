import falcon
import json


class TurnomaticResource(object):
    cnt = 0
    def on_get(self, req, resp, id):
        """Handles GET requests"""
        resp.status = falcon.HTTP_200
        resp.set_header('Content-Type', 'application/json')
        
        resp.body = json.dumps({
            'id': id,
            'turno': TurnomaticResource.cnt
        })
        TurnomaticResource.cnt += 1
        

def create_app():
    app = falcon.API()

    turnomatic = TurnomaticResource()
    app.add_route('/turno/{id}', turnomatic)

    return app
