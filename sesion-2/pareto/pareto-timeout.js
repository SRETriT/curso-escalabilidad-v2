const total = 100000
const percents = [5, 50, 90, 99, 99.9]
const array = []
const series = 10
const parallel = 10
const timeout = 100

console.log(`Pareto: ${series} calls in series, each one ${parallel} calls in parallel`)
let min = Infinity
let max = 0
let sum = 0
for (let i = 0; i < total; i++) {
	const pareto = getSample()
	array.push(pareto)
	sum += pareto
	if (pareto > max) max = pareto
	if (pareto < min) min = pareto
}
console.log(`min: ${min}, max: ${max}, avg: ${sum/total}`)

function getSample() {
	let sum = 0
	for (let i = 0; i < series; i++) {
		const parallel = getParallel()
		sum += parallel
	}
	return sum
}

function getParallel() {
	let max = 0
	for (let i = 0; i < parallel; i++) {
		const pareto = getPareto()
		if (pareto > max) {
			max = pareto
		}
	}
	return max
}

function getPareto() {
	const pareto = 28/Math.random()**(1/1.16)
	// we add a timeout: if bigger than timeout, retry (timeout + sample)
	if (pareto > timeout) return timeout + getPareto()
	return Math.round(pareto)
}

array.sort((a, b) => a - b)

for (const percent of percents) {
	const value = array[total * percent / 100]
	console.log(`percentile ${percent}: ${value}`)
}

