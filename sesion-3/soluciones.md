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

