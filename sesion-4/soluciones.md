# Soluciones a la sesión 4

_Spoiler alert_:
Evita leer las soluciones antes de intentar los ejercicios por tu cuenta.

## Ejercicio: Cambios compatibles

Para añadir el campo opcional `username` a `User` no hay problema,
ya que es opcional.
La nueva API será:

```
createUser({email, username?, password}) → {userId, email, username?, password}
modifyUser(userId, {email?, username?, password?}) → modified
login(email, password) → {userId, token}
deleteUser(userId) → deleted
```

Los clientes existentes seguirán usando las llamadas alegremente,
posiblemente recibiendo un nuevo campo `username` que se puede ignorar sin problemas.

Para hacer obligatorio el campo `username` la cosa cambia.
Si simplemente ponemos el campo como obligatorio las llamadas existentes fallarán.
Una forma de mantener la compatibilidad es:

* crear nuevas funciones,
* marcar las funciones existentes como `deprecated`
* y asignar un valor por defecto a los usuarios existentes.

La API será ahora:

```
createUser({email, username?, password}) → {userId, email, username?, password} [deprecated]
createNewUser({email, username, password}) → {userId, email, username, password}
modifyUser(userId, {email?, username?, password?}) → modified
login(email, password) → {userId, token}
deleteUser(userId) → deleted
```

Sólo tendremos que actualizar la versión _minor_.
Mientras los usuarios sigan llamando a las funciones antiguas seguirán añadiéndose
usuarios con el `username` por defecto.

Para eliminar `deleteUser()` marcamos la función como `deprecated`
y subimos la versión _minor_.
Cuando nos aseguramos de que la función no se usa,
la eliminamos y aumentamos la versión _major_ (rotura de compatibilidad).

**Truco:** Lo mejor es a menudo ignorar a la gente de negocio;
es posible que los requisitos cambien en cualquier momento.
Por ahora añadimos una alerta a `deleteUser()`,
y monitorizamos que no se use.

## Ejercicio: Diseña tu dashboard

Se resolverá en directo.

## Ejercicio: Agente de Prometheus

Se resolverá en directo.

## Ejercicio: Usando honeycomb.io

Se resolverá en directo.

## Ejercicio: Despliegue canario

Posibles estrategias:

### Feature flags

Las _feature flags_
o [_feature toggles_](https://martinfowler.com/articles/feature-toggles.html)
ayudan a hacer despliegues "oscuros",
es decir: poner el código en producción pero oculto para el uso normal.
Es posible ampliar la técnica para que sólo se active el código en ciertos servidores,
para usuarios selectos, etcétera.

### Despliegue _blue-green_

Se crean dos juegos de servidores idénticos,
uno que llamaremos _blue_ y otro _green_.
Se pone en producción un juego de servidores en cada momento,
alternando.

Cuando hay que hacer un despliegue y están los servidores _blue_ en producción,
se despliega el nuevo código en los servidores _green_.
A continuación se quitan de servicio los servidores _blue_
y se ponen los _green_.
Si hay algún error el rollback es inmediato:
se vuelven a activar los _blue_ y se decomisionan los _green_.
Para el siguiente despliegue se invierten los papeles,
desplegando en _blue_ y quitando de servicio los _green_.

Ventajas:

* Despliegue rápido.
* Rollback rápido.
* Se cuenta con un juego de servidores adicional para emergencias.

Desventajas:

* Incrementa costes y esfuerzo de mantenimiento.
* Posible tiempo sin servicio.
* Es difícil combinar con cambios en la base de datos.

### Tráfico duplicado

Se crea un servidor idéntico a los de producción,
conectado a una base de datos que sea una réplica de producción.
Se duplica el tráfico entrante,

Ventajas:

* Se eliminan las incógnitas desconocidas o _unknown unknowns_,
al recibir tráfico real en un entorno realista.

Desventajas:

* Complejidad inabordable para cualquiera que no sea GitHub.

### Migraciones de base de datos

Es interesante siempre mantener la [compatibilidad hacia atrás](https://www.joelonsoftware.com/2004/06/13/how-microsoft-lost-the-api-war/),
como hace [Microsoft en sus sistemas operativos](https://devblogs.microsoft.com/oldnewthing/20080324-00/?p=23033).

Este artículo describe
[múltiples estrategias](https://pinchito.es/2015/arquitectura-fluida-2-estrategias-migracion)
para base de datos.

[Esta herramienta](https://github.com/guidesmiths/marv)
de GuideSmiths ayuda con las migraciones de base de datos.

### Otras técnicas interesantes

* [Chaos Engineering](https://github.com/Netflix/chaosmonkey):
tirar servidores, racks e incluso datacenters enteros para ver cómo se comporta el sistema.
* Troll Engineering: lanzar alertas en plan simulacro para ver cómo reaccionan las partes responsables.

## Ejercicio: Descriptores de fichero

Comprobamos el límite de descriptores de fichero actual:

    $ ulimit -n
    1024

Arrancamos el [servidor con retardo](./retardo.js):

    $ node retardo.js
    Server running at http://127.0.0.1:3500/

Comprobamos en la [URL local](http://127.0.0.1:3500/) que el servidor responda a los 10 segundos.
Desde otra consola aumentamos los descriptores de fichero:

    $ ulimit -n 60000
    $ ulimit -n
    60000

(Si diera error o el límite no se incrementara,
puede ser necesario seguir [estas instrucciones](https://glassonionblog.wordpress.com/2013/01/27/increase-ulimit-and-file-descriptors-limit/).)
El límite se fija para cada consola.
Es importante que el servidor tenga 1024 y el cliente 60000.

A continuación lanzamos las pruebas de carga con concurrencia 10000:

    $ loadtest -c 10000 -n 10000 --rps 1000 http://localhost:3500/
    [... tras unos segundos]
    INFO Target URL:          http://localhost:3500/
    [...]
    INFO Completed requests:  10000
    INFO Total errors:        9020
    INFO    -1:   9020 errors

El servidor está dando errores por falta de conexiones,
no han entrado ni 1000 peticiones.

Ahora paramos el servidor y aumentamos también el límite de descriptores de fichero en esa consola:


    $ ulimit -n 60000
    $ ulimit -n
    60000
    $ node retardo.js
    Server running at http://127.0.0.1:3500/

Relanzamos las pruebas en la consola del cliente:

    $ loadtest -c 10000 -n 10000 --rps 1000 http://localhost:3500/
    [... tras unos segundos]
    INFO Target URL:          http://localhost:3500/
    [...]
    INFO Completed requests:  10000
    INFO Total errors:        0

Ahora el servidor es capaz de responder a todas las 10k peticiones en vuelo.

