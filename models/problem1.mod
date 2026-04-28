/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:35:30 AM
 *********************************************/
 
// =====================================================
// PROBLÈME D’ATTERRISSAGE D’AVIONS - PROBLÈME 1
// Minimisation des pénalités pondérées d’avance et de retard
// =====================================================


// ======================
// ENSEMBLES
// ======================

int n = ...;
range I = 1..n;				// Ensemble des avions

int m = ...;
range R = 1..m;			 	// Ensemble des pistes


// ======================
// PARAMÈTRES
// ======================

float E[I] = ...;        // Dates d’atterrissage les plus tôt
float L[I] = ...;        // Dates d’atterrissage les plus tard
float T[I] = ...;        // Dates d’atterrissage cibles

float cMinus[I] = ...;   // Poids de pénalité pour avance
float cPlus[I]  = ...;   // Poids de pénalité pour retard

float s[I][I] = ...;     // Temps de séparation

float M = ...;


// ======================
// VARIABLES
// ======================

dvar float+ x[I];        // temps d’atterrissage
dvar float+ alpha[I];    // avance (écart anticipé)
dvar float+ beta[I];     // retard (écart tardif)

dvar boolean z[I][I];    // ordre (i avant j)


// ======================
// OBJECTIF
// ======================

minimize
   sum(i in I)
      (cMinus[i] * alpha[i] + cPlus[i] * beta[i]);


// ======================
// CONTRAINTES
// ======================

subject to {

   // =====================================================
   // 1. Fenêtres de temps
   // Chaque avion doit respecter son intervalle autorisé
   // =====================================================
   forall(i in I)
      E[i] <= x[i] <= L[i];


   // =====================================================
   // 2. Définition avance / retard
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