/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:39:04 AM
 *********************************************/

// =====================================================
// PROBLÈME D’ATTERRISSAGE D’AVIONS - PROBLÈME 2
// Minimisation du makespan (temps du dernier atterrissage)
// =====================================================


// ======================
// ENSEMBLES
// ======================

int n = ...;
range I = 1..n;              // Ensemble des avions

int m = ...;
range R = 1..m;              // Ensemble des pistes


// ======================
// PARAMÈTRES
// ======================

float E[I] = ...;            // Dates d’atterrissage les plus tôt
float L[I] = ...;            // Dates d’atterrissage les plus tard

float s[I][I] = ...;         // Temps de séparation

float M = ...;               // Constante Big-M


// ======================
// VARIABLES
// ======================

dvar float+ x[I];            // temps d’atterrissage

dvar boolean y[I][R];        // affectation (i sur la piste r)

dvar boolean z[I][I];        // ordre (i avant j)

dvar float+ Cmax;            // makespan (dernier temps d’atterrissage)


// ======================
// OBJECTIF
// ======================

minimize Cmax;               // Minimiser le temps du dernier atterrissage


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
   // 2. Définition du makespan
   // Cmax est supérieur ou égal à tous les temps d’atterrissage
   // =====================================================
   forall(i in I)
      x[i] <= Cmax;


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
   // Appliquées uniquement si deux avions sont sur la même piste
   // =====================================================
	forall(i in I, j in I : i != j)
	   forall(r in R) {
	
	      x[j] >= x[i] + s[i][j]
	              - M * (1 - z[i][j])
	              - M * (2 - y[i][r] - y[j][r]);
	
	      x[i] >= x[j] + s[j][i]
	              - M * (1 - z[j][i])
	              - M * (2 - y[i][r] - y[j][r]);
	   }

}

execute {
  writeln("Objective value = ", cplex.getObjValue());
  writeln("Landing times x = ", x);
}