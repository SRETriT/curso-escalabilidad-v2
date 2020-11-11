# Soluciones a la sesión 1

_Spoiler alert_:
Evita leer las soluciones antes de intentar los ejercicios por tu cuenta.

## Ejercicio: Servicio poco escalable

Al lanzar las pruebas de carga en local el rendimiento será bastante malo.

Desde el servidor la respuesta estará seguramente alrededor de 300 rps.
La latencia media tiende a estar alrededor de 300 ms.
No debería haber errores.

Puede ser interesante lanzar el servicio en una consola:

$ node slow-rest-api/index.js

y las pruebas desde otra consola, en la misma máquina:

$ loadtest http://localhost:3000/a -n 2000 -c 100 --keepalive

Los resultados no serán realmente mucho mejores.

Al ajustar las RPS la respuesta no subirá de estas 300 rps,
aunque tampoco debería hundirse demasiado.

Al probar contra http://service.pinchito.es:3000/d
la respuesta debería mejorar sustancialmente,
hasta las 700 u 800 rps.
Esto indica algún problema de rendimiento en http://service.pinchito.es:3000/a.

## Ejercicio: Almacenamiento

Las dos opciones son:

### Opción 1: SAN

Solución integrada. Coste total: $22439 ($1.50/GB).

### Opción 2: discos en bruto

* discos duros de 1 TB por $75, $0.07/GB. 15 discos, coste: $1125.
* Añadimos redundancia 2x (RAID 1). 30 discos, coste: $2250.
* Añadimos controladores: 1 servidor barato ($1000) por cada 8 discos.
Coste: $4000.
* Coste total: $4000 + $2250 = $6250.

### Estrategias de escalado

Para ampliar la opción 1 es necesario tirar la cabina y comprar una nueva,
ya que ésta está ya al máximo de capacidad.

Para ampliar la opción 2 compramos más discos y más controladores.
Necesitamos algún tipo de software que nos permita usar múltiples discos y controladores como una única unidad,
por ejemplo ZFS.

## Ejercicio: Almacenamiento escalable

Resuelto en la presentación.

## Ejercicio: Diseña un cajero automático

Solución inicial: damos dinero con un límite
marcado por el departamento de riesgos.
Marcamos en la tarjeta cuando se ha retirado sin conexión,
para evitar fraudes repetidos.

Algoritmo de conciliación:

* Cada operación se marca con un código único.
* Recorremos el log de operaciones del cajero.
* Para cada operación, la pasamos al servidor con la hora actual al hacer la conexión
(no la hora de la operación sin conexión en el cajero).
Buscamos el código único de la operación entre las ya realizadas.
Si el código ya se ha procesado se rechaza la operación.
En caso contrario se realiza la operación, y se guarda su código junto con la operación.
* Todas las operaciones son atómicas (se realizan en un único paso),
para evitar errores por la sincronización.

## Ejercicio: Control de costes

Coste de instancias:

* Redis gestionado: el menor coste por GB es con instancias
`cache.r6g`. Elegimos la `cache.r6g.2xlarge`, $0.821 / hora, $591 / mes.

* Redis instalado: `r6g.2xlarge`, $0.4032 / hora, $290 / mes.
Tiene incluso más memoria (64 GB frente a 53 GB).
El coste es prácticamente la mitad.

La relación se mantiene al usar instancias reservadas.

Añadimos costes de mantenimiento:

* Redis instalado: $150 + ($50 + $290) * instancias.

* Redis gestionado: $75 + ($25 + $591) * instancias.

* Redis gestionado sale más caro incluso con los costes de mantenimiento más elevado.

El coste del mantenimiento es orientativo y depende mucho de la situación;
sustituye tus propios datos para obtener algo más realista.

## Ejercicio: Control de costes (II)

Comparación de costes _serverless_ con servidores propios.

### AWS Lambda

Precio por petición (512 MB, 100ms): $0.0000008333.
Coste mensual de AWS Lambda: $0.0000008333 * 100 * 3600 * 24 * 30 = $216.

### Instancias

Tiempo total: 100 * 100 ms = 10000 ms cada segundo = 10 CPUs.
Contando 4 procesos al 50% de ocupación se queda en 5 CPUs.
Elegimos 5 instancias `t2.small`, coste unitario $0.023 / hora,
coste 5 * $0.023 / hora = $0.115 / hora = $83 / mes.

Coste total mensual de instancias con 4 procesos al 50% de ocupación: $83.
Si tenemos que mantener instancias para mantener el pico de carga de 300 rps: coste x3 = $249.
¡Más caro que AWS Lambda!

Sumamos $150 por servidor de mantenimiento:
$83 + 5 * $150 = $833 / mes, bastante más caro que AWS Lambda.
Nos conviene elegir instancias más grandes para reducir el coste por mantenimiento:
`c6g.xlarge` con 4 CPUs. A $0.136 / hora = $98 / mes + 150 de mantenimiento,
todavía más que AWS Lambda.

Si conseguimos mantener el uso de máquinas al 80% de CPU
de media bastaría con 10 CPUs / 4 procesos / 0.80 = 3.125 CPUs.
El coste no cambia apenas, siempre hay que redondear hacia arriba.

EC2 sale rentable con máquinas más grandes todavía,
o si conseguimos reducir el mantenimiento por máquina.


## Ejercicio: Dispositivo de presencia.

Primero debe arrancarse una instancia de Redis.
Anotar IP y puerto.
Después hay que modificar el fichero [canary.js](./canary/canary.js)
para apuntar a la instancia de Redis.

A continuación debe empaquetarse el código del directorio [canary](./canary/)
en un fichero `.zip`, y subirlo a AWS Lambda.
Al invocarlo escribirá en Redis un valor canario
que permite saber si nuestro servicio está funcionando.

