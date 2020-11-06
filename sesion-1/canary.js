const redis = require('redis');
const client = redis.createClient({
	host: 'localhost',
	port: 6379,
});

client.on('error', function(error) {
	console.error(error);
});

client.get('canary', (error, result) => {
	console.log(`Read canary ${result}`)
	client.set('canary', 'alive', 'EX', 3 * 60, error => {
		console.log('Canary refreshed')
		client.quit()
	});
})

