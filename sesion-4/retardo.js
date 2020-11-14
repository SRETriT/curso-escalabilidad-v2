const http = require('http')

const port = 3500
const delayMs = 10000

const server = http.createServer((req, res) => {
	setTimeout(() => {
		res.statusCode = 200
		res.setHeader('Content-Type', 'text/plain')
		res.end('Hello World')
	}, delayMs)
})

server.listen(port, () => {
  console.log(`Server running at http://127.0.0.1:${port}/`)
})

