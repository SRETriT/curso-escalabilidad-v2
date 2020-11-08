# Soluciones a la sesión 2

_Spoiler alert_:
Evita leer las soluciones antes de intentar los ejercicios por tu cuenta.

## Ejercicio: Pruebas de carga

Pruebas contra http://service.pinchito.es:3000/a.

### Diferentes herramientas

* ab: 305 rps, latency 327 ms.
* wrk2: 35 rps, latency 16 ms.
* loadtest: 332 rps, latency 282 ms.
* autocannon: 349 rps, latency 1092 ms.

La frecuencia natural es alrededor de 330 rps para todas las herramientas
menos para wrk2.

Los resultados varían bastante entre ejecuciones,
seguramente por la diferente carga de la máquina.

### Tasa de RPS constante

* loadtest 300 rps: 290 rps, latency 12 ms.
* loadtest 400 rps: 331 rps, latency 657 ms.
* autocannon 200 rps: 204 rps, latency 240 ms.
* autocannon 300 rps: 307 rps, latency 352 ms.
* autocannon 400 rps: 342 rps, latency 1069 ms.

Tanto con `loadtest` como con `autocannon` se nota una clara "rodilla" alrededor de la frecuencia natural:
la latencia se dispara con `loadtest` de 12 a 657 ms,
y con `autocannon` de ~300 a más de 1000 ms.

### Servicio mejor diseñado

Pruebas contra http://service.pinchito.es:3000/d.

* ab: 959 rps, latency 104 ms.
* wrk2: 30 rps, latency 58 ms.
* loadtest: 931 rps, latency 105 ms.
* autocannon: 776 rps, latency 504 ms.

Los resultados cambian drásticamente.
El problema de rendimiento presente en `/a`
probablemente no existe en `/d`.

## Ejercicio: Diseña un temporizador

Modo agresivo a 10 rps:
se lanza una petición cada 100 ms.
(Node.js: `setInterval()`.)

Si una petición tarda demasiado se debe lanzar la siguiente
en un hilo (y una conexión) aparte.

Si hay un retraso del sistema podemos compensar lanzando varias peticiones.

Para tasas fraccionales podemos de nuevo lanzar varias peticiones por llamada.

Para lanzar más de 1000 rps (con temporizadores con resolución de 1 ms)
es necesario lanzar varias peticiones por llamada.

En todos estos casos las peticiones se pueden acumular.

Una solución más completa es un
[timer preciso](https://github.com/alexfernandez/loadtest/blob/master/lib/hrtimer.js).
Supongamos una frecuencia R de peticiones por segundo.
El intervalo en milisegundos sería de 1000 / R.

* En el momento 0 lanzamos una petición.
* Calculamos los ms hasta que haya que lanzar la siguiente, ponemos un timeout y esperamos.
(Node.js: `setTimeout()`.)
* Cuando nos despierte el timeout lanzamos una petición.
* Ahora calculamos los ms desde el inicio,
y el número de peticiones que tendríamos que haber enviado.
Para un tiempo en milisegundos T, las peticiones deberían ser: R * T / 1000 + 1.
* Comparamos con las peticiones que de hecho hemos enviado.
Si vamos con retraso (tendríamos que haber lanzado ya la siguiente petición),
llamamos de nuevo inmediatamente.
(Node.js: `setImmediate()`.)
* En caso contrario volvemos a calcular los ms hasta la siguiente petición y ponemos un nuevo timeout.
(Node.js: `setTimeout()`.)
Timeout t para peticiones p en tiempo T: (p - R * T / 1000 + 1) * 1000 / R.

## Ejercicio: Tiempo total

Percentil 50: 50 ms.
Percentil 90: 200 ms.

### Cota mínima

Cota mínima para el tiempo medio:
(5 x 0 + 4 x 50 + 1 x 200) / 10 = 40 ms.

Estimación algo más realista:
(5 x 25 + 4 x 100 + 1 x 400) / 10 = 92 ms.

### Distribución de pareto

Mínimo 28, media 160~300, mediana (percentil 50) 51.
Ver [código](pareto/pareto-initial.js).

### Llamadas en paralelo

Mínimo 38, media 1000~1800, mediana 287~288.
Ver [código](pareto/pareto-parallel.js).

### Llamadas en serie

Mínimo 488, media 1700~2100, mediana 883~888.
Ver [código](pareto/pareto-series.js).

### Llamadas en serie x en paralelo

Mínimo 1150~1200, media 12000~15000, mediana 5620~5623.
Ver [código](pareto/pareto-combined.js).

Es posible mejorar la respuesta añadiendo un timeout,
por ejemplo de 100 ms.

Los resultados ahora son mucho más estables,
además de haber mejorado un montón.
Mínimo 1140~1160, media 2050, mediana 2033.
Ver [código](pareto/pareto-combined.js).

## Ejercicio: Límites de optimización

Tasa de RPS: R = 1000000 / t,
donde t es el tiempo en microsegundos.

Original: R0 = 1000000 / (2 + 6 + 7 + 12) = 37k.
Optimizamos string y procesamiento,
máximo teórico:
RM = 1000000 / (7 + 12) = 52600.

Otras estrategias posibles pasan por reducir el input y el output:

* Cambiar el formato de entrada y de salida para abreviar tiempos.
* Comprimir los datos.
* Usar alguna librería de entrada y salida más rápida.

## Ejercicio: Distribución real

Arrancamos una instancia con la imagen
`pinchito-loadtest-2020-11-08`.
Ejecutamos:

```
cd loadtest
```

El paquete `loadtest` ya está trucado para mostrar los tiempos.

Resultados:
[300 rps](https://docs.google.com/spreadsheets/d/16aEiZ5NIuUd5VohSyv4j1JbgXt5f5DikoJLZNI1RfXA/edit#gid=1830277567),
[500 rps](https://docs.google.com/spreadsheets/d/16aEiZ5NIuUd5VohSyv4j1JbgXt5f5DikoJLZNI1RfXA/edit#gid=674195216).
Obsérvense los tiempos tan locos a 500 rps.

## Ejercicio: Ahorrando microsegundos

Veamos una versión reducida:
[código instrumentado](pareto/pareto-instrumented.js).
Ejecutar primero `npm i microprofiler`.

Al ejecutar `node pareto-instrumented.js` vemos que cada iteración tarda unos 1.7 µs
(en mi máquina).

### `pareto-simulator`

El código de `computeSample()` quedaría así:

```
function computeSample() {
    const start = profiler.start()
    if (options.parallel == 1 && options.series == 1) {
        return computePareto()
    }
    let sum = 0
    for (let i = 0; i < options.series; i++) {
        let max = 0
        for (let j = 0; j < options.parallel; j++) {
            const sample = computePareto()
            if (sample > max) max = sample
        }
        sum += max
    }
    profiler.measureFrom(start, 'sample', 10000)
    return sum
}
```

Cada iteración tarda unos 150 µs (en mi máquina).
Es difícil optimizar un par de bucles tan compactos,
pero ¡inténtalo! :)

### Node profiler

En el profiler se ve claramente el tiempo de `sort()`.
Se incluye una [traza](pareto/isolate-0x5f618d0-658474-v8.log).
Comando:

```
node --prof-process isolate-0x5f618d0-658474-v8.log
```

Partes interesantes:

```
 [Summary]:
   ticks  total  nonlib   name
   1843   34.0%   93.2%  JavaScript
    115    2.1%    5.8%  C++
    152    2.8%    7.7%  GC
   3442   63.5%          Shared libraries
     20    0.4%          Unaccounted
```

Una tercera parte es JavaScript, el resto casi todo librerías.

```
   1487   27.4%   75.2%  LazyCompile: *<anonymous> /home/alex/projects/curso-escalabilidad-v2/sesion-2/pareto.js:36:12
    258    4.8%   13.0%  LazyCompile: *<anonymous> /home/alex/projects/curso-escalabilidad-v2/sesion-2/pareto.js:1:1
```

Un 27% se va en ordenar el array.
Sería interesante usar una solución para el cálculo de percentiles que no implique ordenar un array gigante.

Este profiler es mucho más preciso,
pero menos ágil: hay que generar traza, leerla e interpretar los resultados.


