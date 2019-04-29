# Power flow solution in distribution networks with PV nodes
Code in Matlab to solve the problem of the power flow in radial network with distributed generation.

In this first approach to the problem, the implemented solution does not inluye PV nodes.

<p align="center">
  <img width="600" height="300" src="http://drive.google.com/uc?export=view&id=1J5aTTDzJQCf4lm0Lc8kwWw6tZICWD7vr">
</p>

In the upper image it is possible to appreciate the IEEE system of 33 distribution bars, in which the algorithm was simulated.

The method implemented for the analysis of the radial distribution network is based on the backward algorithm, which considers in each iteration the loads in the bus modeled as constant impedances calculated based on the bus power and voltage. Once the busr voltages have been determined, they are compared to what has been used to evaluate the load impedances. If the error (in each bur) is less than a predetermined value (tolerance), the iterative process stops, otherwise another iteration is started.

## Next updates
* ~~Implement the algorithm in radial network with bifurcations.~~
* ~~Implement the algorithm in any radial network with bifurcations.~~
* Include PV nodes.

## References
```
[1] A backward sweep method for power flow solution in distribution networks - A. Augugliaro, L. Dusonchet, S. Favuzza *, M.G. Ippolito, E. Riva Sanseverino (2009)
```
