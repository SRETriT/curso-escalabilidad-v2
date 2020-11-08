const profiler = require('microprofiler')
const total = 1000000
const percents = [5, 50, 90, 99, 99.9]
const array = []
const serie = 10

let min = Infinity
let max = 0
let sum = 0
for (let i = 0; i < total; i++) {
	const start = profiler.start()
	const pareto = getSample()
	array.push(pareto)
	sum += pareto
	if (pareto > max) max = pareto
	if (pareto < min) min = pareto
	profiler.measureFrom(start, 'stats', 1000000)
}
console.log(`min: ${min}, max: ${max}, avg: ${sum/total}`)

function getSample() {
	let sum = 0
	for (let i = 0; i < serie; i++) {
		const pareto = getPareto()
		sum += pareto
	}
	return sum
}

function getPareto() {
	const pareto = 28/Math.random()**(1/1.16)
	if (pareto > 100) return 100 + getPareto()
	return pareto
}

array.sort((a, b) => a - b)

for (const percent of percents) {
	const value = array[total * percent / 100]
	console.log(`percentile ${percent}: ${value}`)
}

