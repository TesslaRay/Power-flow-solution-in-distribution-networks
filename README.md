# Power flow solution in distribution networks with PV nodes
Código en Matlab para resolver el problema de flujo de potencia en una red radial con generación distribuida

En esta primera aproximación al problema la solución implementada no incluye nodos PV en su resolución.

<p align="center">
  <img width="600" height="300" src="http://drive.google.com/uc?export=view&id=1J5aTTDzJQCf4lm0Lc8kwWw6tZICWD7vr">
</p>

En la imagen superior es posible apreciar el sistema IEEE de 33 barras de distribución, en el cual se simulo el algoritmo.

El mètodo implementado para el análisis de la red de distribución radial es basado en el algoritmo backward, que considera en cada iteración las cargas en los nodos modeladas como impedancias constantes calculadas en función de la potencia y la tensión de la barra. Una vez que se han determinadp los voltajes de barra, se comparan con lo que se han utilizado para evaluar las impedancias de carga. Si el error( en cada barra) es menor a un valor prefijado (tolerancia), el proceso iterativo se detiene, de lo contrario se inicia otra iteración.

## Próximas mejoras
* ~~Implementar el algoritmo en red radial con bifurcaciones.~~
* ~~Implementar el algortmo en cualquier red radial con bifurcaciones.~~
* Incluir nodos PV.

## Referencias
```
[1] A backward sweep method for power flow solution in distribution networks - A. Augugliaro, L. Dusonchet, S. Favuzza *, M.G. Ippolito, E. Riva Sanseverino (2009)
```
