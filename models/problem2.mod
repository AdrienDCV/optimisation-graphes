/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:39:04 AM
 *********************************************/

// =====================================================
// AIRCRAFT LANDING PROBLEM - PROBLEM 2
// Minimisation du makespan (temps du dernier atterrissage)
// Version multi-pistes
// =====================================================


// ======================
// SETS (ENSEMBLES)
// ======================

int n = ...;
range I = 1..n;              // Ensemble des avions

int m = ...;
range R = 1..m;              // Ensemble des pistes


// ======================
// PARAMETERS (PARAMÈTRES)
// ======================

float E[I] = ...;            // Temps d’atterrissage le plus tôt autorisé
float L[I] = ...;            // Temps d’atterrissage le plus tard autorisé

float s[I][I] = ...;         // Temps de séparation requis entre deux avions

float M = ...;               // Constante Big-M


// ======================
// VARIABLES DE DÉCISION
// ======================

dvar float+ x[I];            // Temps d’atterrissage de chaque avion

dvar boolean y[I][R];        // =1 si avion i est affecté à la piste r

dvar boolean z[I][I];        // =1 si i atterrit avant j

dvar float+ Cmax;            // Makespan = temps du dernier atterrissage


// ======================
// FONCTION OBJECTIF
// ======================

minimize Cmax;               // Minimiser le temps de fin global (dernier avion)


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
   // => il représente bien le maximum des x[i]
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


// ======================
// AFFICHAGE DES RÉSULTATS
// ======================

execute {
  writeln("Objective value = ", cplex.getObjValue());  // valeur du makespan optimal
  writeln("Landing times x = ", x);                    // planning des atterrissages
}