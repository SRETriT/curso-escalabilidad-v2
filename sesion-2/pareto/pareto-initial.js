const total = 100000
const percents = [5, 50, 90, 99, 99.9]
const array = []
const serie = 10

console.log(`Pareto: one single sample`)
let min = Infinity
let max = 0
let sum = 0
for (let i = 0; i < total; i++) {
	const pareto = getPareto()
	array.push(pareto)
	sum += pareto
	if (pareto > max) max = pareto
	if (pareto < min) min = pareto
}
console.log(`min: ${min}, max: ${max}, avg: ${sum/total}`)

function getPareto() {
	const pareto = 28/Math.random()**(1/1.16)
	return Math.round(pareto)
}

array.sort((a, b) => a - b)

for (const percent of percents) {
	const value = array[total * percent / 100]
	console.log(`percentile ${percent}: ${value}`)
}

