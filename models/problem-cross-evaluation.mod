/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Apr 1, 2026 at 3:33:38 PM
 *********************************************/
 
// =====================================================
// CROSS VALIDATION MODEL - AIRCRAFT LANDING
// Évaluation comparative des solutions P1 / P2 / P3
// (aucune optimisation ici, uniquement du calcul de métriques)
// =====================================================


// ======================
// DIMENSIONS
// ======================

int n = ...;                 
int m = ...;                 


// ======================
// SETS (ENSEMBLES)
// ======================

range I = 1..n;              // Ensemble des avions
range R = 1..m;              // Ensemble des pistes


// ======================
// PARAMETERS (PARAMÈTRES)
// ======================

float T[I] = ...;            // Temps cible (utilisé pour f1)
float cMinus[I] = ...;       // Coût d’avance
float cPlus[I] = ...;        // Coût de retard

float A[I] = ...;            // Deadline finale (utilisée pour f3)

// Temps de roulage dépendant de la piste
float t[I][R] = ...;


// ======================
// SOLUTIONS ENTRÉE
// (issues des modèles P1, P2, P3)
// ======================

float xP1[I] = ...;          // temps d’atterrissage solution P1
float xP2[I] = ...;          // temps d’atterrissage solution P2
float xP3[I] = ...;          // temps d’atterrissage solution P3

// Affectations aux pistes (nécessaires pour f3)
int runwayP1[I] = ...;
int runwayP2[I] = ...;
int runwayP3[I] = ...;


// ======================
// EXECUTION : ÉVALUATION
// ======================

execute {

  writeln("====================================");
  writeln("     MATRICE D'EVALUATION");
  writeln("====================================");

  var i;
  var totalCost;   // valeur de f1 (coût pondéré avance/retard)
  var maxTime;     // valeur de f2 (makespan)
  var totalLate;   // valeur de f3 (retard total)


  // =====================================================
  // ÉVALUATION DE LA SOLUTION X1 (issue de P1)
  // =====================================================
  writeln("\nSolution X1");

  // ----------------------
  // f1 : coût avance / retard
  // ----------------------
  totalCost = 0;
  for(i in I)
    totalCost += cMinus[i] * (T[i] > xP1[i] ? T[i] - xP1[i] : 0)   // avance
               + cPlus[i]  * (xP1[i] > T[i] ? xP1[i] - T[i] : 0);  // retard

  writeln("f1(X1) = ", totalCost);


  // ----------------------
  // f2 : makespan
  // (dernier atterrissage)
  // ----------------------
  maxTime = xP1[1];
  for(i in I)
    if(xP1[i] > maxTime) maxTime = xP1[i];

  writeln("f2(X1) = ", maxTime);


  // ----------------------
  // f3 : retard total (tardiness)
  // basé sur :
  //   temps d’atterrissage + taxi - deadline
  // ----------------------
  totalLate = 0;
  for(i in I) {

    var taxi = t[i][runwayP1[i]];     // sélection du bon temps de roulage
    var val = xP1[i] + taxi - A[i];   // retard brut

    if(val > 0) totalLate += val;     // uniquement retard positif
  }

  writeln("f3(X1) = ", totalLate);


  // =====================================================
  // ÉVALUATION DE LA SOLUTION X2 (issue de P2)
  // =====================================================
  writeln("\nSolution X2");

  // f1
  totalCost = 0;
  for(i in I)
    totalCost += cMinus[i] * (T[i] > xP2[i] ? T[i] - xP2[i] : 0)
               + cPlus[i]  * (xP2[i] > T[i] ? xP2[i] - T[i] : 0);

  writeln("f1(X2) = ", totalCost);

  // f2
  maxTime = xP2[1];
  for(i in I)
    if(xP2[i] > maxTime) maxTime = xP2[i];

  writeln("f2(X2) = ", maxTime);

  // f3
  totalLate = 0;
  for(i in I) {
    var taxi = t[i][runwayP2[i]];
    var val = xP2[i] + taxi - A[i];
    if(val > 0) totalLate += val;
  }

  writeln("f3(X2) = ", totalLate);


  // =====================================================
  // ÉVALUATION DE LA SOLUTION X3 (issue de P3)
  // =====================================================
  writeln("\nSolution X3");

  // f1
  totalCost = 0;
  for(i in I)
    totalCost += cMinus[i] * (T[i] > xP3[i] ? T[i] - xP3[i] : 0)
               + cPlus[i]  * (xP3[i] > T[i] ? xP3[i] - T[i] : 0);

  writeln("f1(X3) = ", totalCost);

  // f2
  maxTime = xP3[1];
  for(i in I)
    if(xP3[i] > maxTime) maxTime = xP3[i];

  writeln("f2(X3) = ", maxTime);

  // f3
  totalLate = 0;
  for(i in I) {
    var taxi = t[i][runwayP3[i]];
    var val = xP3[i] + taxi - A[i];
    if(val > 0) totalLate += val;
  }

  writeln("f3(X3) = ", totalLate);

}