/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:51:51 AM
 *********************************************/

// =====================================================
// AIRCRAFT LANDING PROBLEM - PROBLEM 3 (CORRECTED)
// Minimisation du retard total (Total Lateness)
// Avec affectation aux pistes et temps additionnels
// =====================================================


// ======================
// SETS (ENSEMBLES)
// ======================

int n = ...;
int m = ...;

range I = 1..n;              // Ensemble des avions
range R = 1..m;              // Ensemble des pistes


// ======================
// PARAMETERS (PARAMÈTRES)
// ======================

float E[I] = ...;            // Temps d’atterrissage minimum autorisé
float L[I] = ...;            // Temps d’atterrissage maximum autorisé

float A[I] = ...;            // Heure souhaitée / deadline (due date)

float s[I][I] = ...;         // Temps de séparation entre i puis j

float t[I][R] = ...;         // Temps additionnel dépendant de la piste
                             // (ex : roulage, accès terminal, etc.)

float M = ...;               // Constante Big-M


// ======================
// VARIABLES DE DÉCISION
// ======================

dvar float+ x[I];            // Temps d’atterrissage de l’avion i

dvar boolean y[I][R];        // =1 si i est affecté à la piste r

dvar boolean z[I][I];        // =1 si i atterrit avant j

dvar float+ Late[I];         // Retard de l’avion i (tardiness)


// ======================
// FONCTION OBJECTIF
// ======================

// Minimiser la somme des retards (pas de pénalité d’avance ici)
minimize sum(i in I) Late[i];


// ======================
// CONTRAINTES
// ======================

subject to {

   // ----------------------
   // 1. Fenêtres de temps
   // Chaque avion doit atterrir dans son intervalle autorisé
   // ----------------------
   forall(i in I)
      E[i] <= x[i] <= L[i];


   // ----------------------
   // 2. Affectation aux pistes
   // Chaque avion est assigné à exactement une piste
   // ----------------------
   forall(i in I)
      sum(r in R) y[i][r] == 1;


   // ----------------------
   // 3. Définition de l’ordre
   // ----------------------

   // Pas d’auto-précédence
   forall(i in I)
      z[i][i] == 0;

   // Pour chaque paire, un seul ordre possible
   forall(i in I, j in I : i < j)
      z[i][j] + z[j][i] == 1;


   // =====================================================
   // 4. Contraintes de séparation (sécurité)
   //
   // Actives uniquement si :
   //   - même piste
   //   - ET ordre choisi
   // =====================================================
   forall(i in I, j in I : i != j, r in R) {

      // Si i avant j sur la piste r
      x[j] >= x[i] + s[i][j]
              - M * (1 - z[i][j])              // désactive si i n’est pas avant j
              - M * (2 - y[i][r] - y[j][r]);   // désactive si pistes différentes

      // Cas symétrique : j avant i
      x[i] >= x[j] + s[j][i]
              - M * (1 - z[j][i])
              - M * (2 - y[i][r] - y[j][r]);
   }


   // ----------------------
   // 5. Définition du retard (lateness)
   //
   // Lateness = (temps réel d’arrivée au "système final")
   //            - deadline A[i]
   //
   // Ici on ajoute :
   //   - temps d’atterrissage x[i]
   //   - temps dépendant de la piste t[i][r]
   // ----------------------
   forall(i in I) {

      // retard >= (temps total - deadline)
      Late[i] >= x[i]
                 + sum(r in R)(t[i][r] * y[i][r])   // sélection du bon t[i][r]
                 - A[i];

      // pas de retard négatif (on ignore l’avance)
      Late[i] >= 0;
   }

}


// ======================
// AFFICHAGE DES RÉSULTATS
// ======================

execute {
  writeln("Objective value = ", cplex.getObjValue());  // retard total minimal
  writeln("Landing times x = ", x);                    // planning d’atterrissage
  writeln("Runway assignment y = ", y);                // affectation aux pistes
  writeln("Ordering matrix z = ", z);                  // ordre entre avions
  writeln("Lateness = ", Late);                        // retard individuel
}