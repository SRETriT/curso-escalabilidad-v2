const request = require('basic-request')

measure().catch(console.error)

async function measure() {
	const start = Date.now()

	await request.get('http://service.pinchito.es:3000/a')

	const elapsed = Date.now() - start
	console.log(`Elapsed: ${elapsed} ms`)
}

