# Soluciones a la sesión 3

_Spoiler alert_:
Evita leer las soluciones antes de intentar los ejercicios por tu cuenta.

## Ejercicio: ¿Cómo medir el tráfico?

Una forma típica (interna) es medir el tráfico usando logs:
un programa que procesa el log de Apache o nginx
y dibuja una gráfica con las peticiones.

Otra forma común (externa) es medir el tráfico en el balanceador,
por ejemplo en el ELB de Amazon.
Sólo posible cuando el tráfico está centralizado.

Las pruebas de carga son una forma controlada de medir tráfico.

Las mejores formas son siempre externas.

## Ejercicio: Midiendo latencias

Bajar el [repositorio del curso](https://github.com/SRETriT/curso-escalabilidad-v2/)
en la máquina.

Cambiar al directorio `latency`:

    $ cd sesion-3/latency
    $ npm install
    $ node latency-a.js
    $ node latency-d.js

La latencia en /d suele salir algo más alta que /a,
pero es difícil medir la diferencia desde fuera de la máquina.

## Ejercicio: Ejercicio: Programación funcional

Una forma de acelerar la solución con el `for()` es sacando la comprobación de longitud fuera del bloque:

```
function solve(limit, array) {
    let t = 0
	let l = array.length
    for (let i = 0; i < l; i++) {
        if (array[i] > limit) t++
    }
    return t
}
```

A menudo se consigue lo mismo recorriendo el array al revés:

```
function solve(limit, array) {
    let t = 0
    for (let i = array.length - 1; i >= 0; i--) {
        if (array[i] > limit) t++
    }
    return t
}
```

## Ejercicio: Contador de visitas

Algunos posibles cuellos de botella en un servidor monoproceso en Node.js escribiendo a fichero son:

* Servidor monoproceso: se podrían añadir más procesos.
* Escritura a fichero: es complicado escribir a ficheros desde múltiples procesos.
Sería mejor usar una base de datos, aunque fuera alojada en el mismo servidor.
* Descriptores de fichero: se debería aumentar el límite.
* Un único servidor: se podrían usar múltiples servidores,
esta vez con una base de datos distribuida.
* La propia base de datos se puede volver un nuevo cuello de botella.

## API

Son sólo necesarias dos operaciones en la API:

* `incrementVisit(id)`: aumentar una visita a un vídeo identificado por id.
* `getVisits(id)`: obtener las visitas de un vídeo identificado por id.

Se puede usar una estrategia elemental de escalado horizontal,
usando una base de datos compartida en red.

### Expansión internacional

Para gestionar una expansión internacional es necesario añadir un cluster
(servidores + base de datos)
por cada región.
El problema es ahora cómo obtener una cuenta de visitas global:
es imposible pedir la cuenta de cada región en tiempo real,
por lo que es más factible actualizarla periódicamente.
En cada intervalo interpolaremos las visitas teniendo en cuenta la tasa de aumento media.

Para cualquier volumen de peticiones no trivial es prácticamente imposible tener un contador a la vez preciso y sincronizado.

### Servidor para asignar identificadores únicos

Es complicado asignar identificadores únicos secuenciales entre varias regiones.
Una opción es asignar bloques de identificadores a cada región,
y tirar de ellos hasta que se agoten.
A continuación (o justo antes de que se termine)
habrá que solicitar un nuevo bloque del servidor central.
Este servidor central se convierte en un nuevo punto único de fallo.

Ver el proyecto de Felipe Polo relacionado:
[block-sequence](https://github.com/guidesmiths/block-sequence).


## Ejercicio: Caídas periódicas

Disponibilidad:

* Banco nacional, 1 hora al día: 1 - 1 / 24 = 95.8%.
* Subastas, 1 hora al mes: 1 - 1 / 24 / 30 = 99.86%.
* Compra online, 5 horas al año: 1 - 5 / 24 / 365 = 99.94%.

### Compromiso de disponibilidad

Con un compromiso del 99.9%,
disponemos de 1440 × 30 × 0.1% = 43 minutos al mes.
Para hacer una intervención de dos horas necesitamos acumular tiempo al menos durante tres meses.
Sería ideal poder hacer la intervención sin tirar el sistema,
aunque sea con degradación del servicio (por ejemplo, en modo de sólo lectura).

Con un compromiso del 99.99% disponemos sólo de 4.3 minutos al mes.
Para actualizar diez servidores tendremos que esperar a un momento de baja carga,
para asegurarnos de que un número limitado de servidores puedan soportarla.
A continuación podemos eliminar cada servidor del balanceo y actualizarlo,
para luego añadirlo de nuevo.

## Ejercicio: Amazon SLA

Según el [SLA de Amazon](https://aws.amazon.com/compute/sla/),
si la disponibilidad baja al 99% Amazon debería darnos un crédito del 10% de la factura,
es decir de €100.
Sin embargo, la letra pequeña indica que el SLA no aplica para
"issues ... caused by factors outside of our reasonable control",
lo que incluye un terremoto.

En general, el servicio debería bajar del 99.99% de disponibilidad para dar un crédito del 10%,
lo que significa más de (1 − .9999) × 1440 × 30 = 4.32 minutos.
Para obtener un 100% será menos del 95%, o sea más de 24 × 30 × 0.05 = **36 horas**.
Una caída de 36 horas en Amazon es algo inaudito y sale en los periódicos.

## Ejercicio: Completa el presupuesto

Con un objetivo de uptime del 99.9% sólo podemos estar caídos
(1 − 0.999) × 24 × 365 = 8.76 horas.
Si ya llevamos siete caídas de una hora nos quedarían 1.76 horas;
estaríamos en el mes 12×7/8.76 = 9.6, o sea mediados de octubre.
Y sólo podríamos hacer un despliegue fallido más (1.76×.66).

Si el percentil 50 es 1 hora y el percentil 90 son 2 horas,
tendríamos que trabajar en mejorar las caídas por despliegues;
por ejemplo implementando un _rollback_ automático.

