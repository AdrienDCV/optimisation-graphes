/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:51:51 AM
 *********************************************/

// =====================================================
// PROBLÈME D’ATTERRISSAGE D’AVIONS - PROBLÈME 3 (CORRIGÉ)
// Minimisation du retard total (retard cumulé)
// Avec affectation aux pistes et temps additionnels
// =====================================================


// ======================
// ENSEMBLES
// ======================

int n = ...;
int m = ...;

range I = 1..n;              // Ensemble des avions
range R = 1..m;              // Ensemble des pistes


// ======================
// PARAMÈTRES
// ======================

float E[I] = ...;            // Dates d’atterrissage les plus tôt
float L[I] = ...;            // Dates d’atterrissage les plus tard

float A[I] = ...;            // Dates cibles (deadlines)

float s[I][I] = ...;         // Temps de séparation

float t[I][R] = ...;         // Temps additionnel dépendant de la piste
                             // (ex : roulage, accès terminal, etc.)

float M = ...;               // Constante Big-M


// ======================
// VARIABLES
// ======================

dvar float+ x[I];            // temps d’atterrissage

dvar boolean y[I][R];        // affectation (i sur la piste r)

dvar boolean z[I][I];        // ordre (i avant j)

dvar float+ Late[I];         // retard


// ======================
// OBJECTIF
// ======================

// Minimiser la somme des retards (pas de pénalité d’avance)
minimize sum(i in I) Late[i];


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
   // 2. Affectation aux pistes
   // Chaque avion est affecté à exactement une piste
   // =====================================================
   forall(i in I)
      sum(r in R) y[i][r] == 1;


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
   forall(i in I, j in I : i != j, r in R) {

      x[j] >= x[i] + s[i][j]
              - M * (1 - z[i][j])
              - M * (2 - y[i][r] - y[j][r]);

      x[i] >= x[j] + s[j][i]
              - M * (1 - z[j][i])
              - M * (2 - y[i][r] - y[j][r]);
   }


   // =====================================================
   // 5. Définition du retard
   // Le retard correspond à l’écart au-delà de la date cible
   // (en tenant compte du temps additionnel de la piste)
   // =====================================================
   forall(i in I) {

      Late[i] >= x[i]
                 + sum(r in R)(t[i][r] * y[i][r])
                 - A[i];

      Late[i] >= 0;
   }

}

execute {
  writeln("Objective value = ", cplex.getObjValue());
  writeln("Landing times x = ", x);
  writeln("Runway assignment y = ", y);
  writeln("Ordering matrix z = ", z);
  writeln("Lateness = ", Late);
}