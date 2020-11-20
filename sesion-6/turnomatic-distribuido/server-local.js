const redis = require('redis')
const http = require('http')

const hostname = '0.0.0.0'
const port = 7017
const redisHost = 'localhost'
const redisPort = 6379

const server = http.createServer(answer)
let client = null
let turno = 0

function answer(request, response) {
	const paths = request.url.split('/')
	if (paths.length < 3 || paths[0] !== '' || paths[1] != 'turno') {
		response.statusCode = 400
		response.end(JSON.stringify({error: `Invalid URL ${request.url}`}, null, '\t'))
		return
	}
	const id = paths[2]
	getRedisResult(id).then(result => {
		response.statusCode = 200
		response.setHeader('Content-Type', 'application/json')
		response.end(JSON.stringify(result, null, '\t'))
	}).catch(error => {
		response.statusCode = 500
		response.end(JSON.stringify({error}))
	})
}

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`)
})

function getRedisResult(id) {
	return new Promise((resolve, reject) => {
		if (!client) {
			initRedis()
		}
		client.incr(id, (error, result) => {
			if (error) return reject(error)
			resolve({id, turno: result})
		})
	})
}

function initRedis() {
	client = redis.createClient({
		host: redisHost,
		port: redisPort,
	})
	client.on('error', function(error) {
		console.error(error)
	})
}

