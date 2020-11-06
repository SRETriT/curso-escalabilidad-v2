const redis = require('redis');

exports.handler = async event => new Promise((resolve, reject) => {
	const client = redis.createClient({
		host: process.env.REDIS_HOST || 'localhost',
		port: 6379,
	});
	
	client.on('error', function(error) {
		console.error(error);
		reject(error);
	});
	
	client.get('canary', (error, result) => {
		if (error) return reject(error);
		console.log(`Read canary ${result}`)
		client.set('canary', 'alive', 'EX', 3 * 60, error => {
			console.log('Canary refreshed');
			client.quit();
			resolve();
		});
	})
});