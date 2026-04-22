/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:35:30 AM
 *********************************************/
 
// =====================================================
// AIRCRAFT LANDING PROBLEM - PROBLEM 1
// Minimizing Weighted Early/Late Penalties
// Single Runway Version
// =====================================================


// ======================
// SETS
// ======================

int n = ...;
range I = 1..n;

int m = ...;
range R = 1..m;


// ======================
// PARAMETERS
// ======================

float E[I] = ...;        // Earliest landing times
float L[I] = ...;        // Latest landing times
float T[I] = ...;        // Target landing times

float cMinus[I] = ...;   // Early penalty weight
float cPlus[I]  = ...;   // Late penalty weight

float s[I][I] = ...;     // Separation times

float M = ...;


// ======================
// VARIABLES
// ======================

dvar float+ x[I];        // landing times
dvar float+ alpha[I];    // early deviation
dvar float+ beta[I];     // late deviation

dvar boolean z[I][I];    // ordering (i before j)


// ======================
// OBJECTIVE
// ======================

minimize
   sum(i in I)
      (cMinus[i] * alpha[i] + cPlus[i] * beta[i]);


// ======================
// CONSTRAINTS
// ======================

subject to {

   // =====================================================
   // 1. Fenêtres de temps
   // Chaque avion doit respecter son intervalle autorisé
   // =====================================================
   forall(i in I)
      E[i] <= x[i] <= L[i];


   // =====================================================
   // 2. Early / Late definition
   // =====================================================
   forall(i in I) {
      alpha[i] >= T[i] - x[i];
      beta[i]  >= x[i] - T[i];

      alpha[i] >= 0;
      beta[i]  >= 0;
   }

   // =====================================================
   // 3. Contraintes d’ordre
   // =====================================================
   // Un avion ne peut pas être avant lui-même
   forall(i in I)
      z[i][i] == 0;

   // Pour chaque paire, un ordre unique est imposé
   // (évite les conflits de séquencement)
   forall(i in I, j in I : i < j)
      z[i][j] + z[j][i] == 1;


   // =====================================================
   // 4. Contraintes de séparation (Big-M)
   // =====================================================
	forall(i in I, j in I : i != j) {
	
	   x[j] >= x[i] + s[i][j]
	           - M * (1 - z[i][j]);
	
	   x[i] >= x[j] + s[j][i]
	           - M * (1 - z[j][i]);
	
	}

}

execute {
  writeln("Objective value = ", cplex.getObjValue());
  writeln("Landing times x = ", x);
}