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


// ======================
// PARAMETERS (given in ALP_Problem1.dat file)
// ======================

float E[I] = ...;            // Earliest landing times
float L[I] = ...;            // Latest landing times
float T[I] = ...;            // Target landing times

float cMinus[I] = ...;       // Weight for early landing
float cPlus[I]  = ...;       // Weight for late landing

float s[I][I] = ...;         // Separation time matrix

float M = ...;               // Big-M constant


// ======================
// DECISION VARIABLES
// ======================

dvar float+ x[I];            // Landing times

dvar float+ alpha[I];        // Early penalty
dvar float+ beta[I];         // Late penalty

dvar boolean y[I][I];        // y[i][j] = 1 if i lands before j


// ======================
// OBJECTIVE FUNCTION
//
// We aim to minimize the total cost of weighted advances and delays
// For each aircraft i:
//  - cMinus[i] * alpha[i] -> penalty if aircraft lands too early
//  - cPlus[i] * beta[i] -> penalty if aircraft lands too late 
//  - sum(i in I) -> sum across all aircraft
// ======================

minimize
   sum(i in I)
      (cMinus[i] * alpha[i] + cPlus[i] * beta[i]);


// ======================
// CONSTRAINTS
// ======================

subject to {

   // ----------------------
   // Time windows
   //
   // Each aircraft must land between its earliest and latest times
   // ----------------------
   forall(i in I)
      E[i] <= x[i] <= L[i];

   // ----------------------
   // Early / Late definition
   //
   // alpha[i] ≥ actual advance → if aircraft arrives after T[i], alpha[i]=0
   // beta[i] ≥ actual delay → if aircraft arrives before T[i], beta[i]=0
   // As alpha[i] and beta[i] are minimised, CPLEX will automatically set the correct value to 0
   // ----------------------
   forall(i in I) {
      alpha[i] >= T[i] - x[i];
      beta[i]  >= x[i] - T[i];
   }

   // ----------------------
   // Ordering constraints
   // ----------------------

   // No self-ordering
   // A plane cannot be ahead of itself
   forall(i in I)
      y[i][i] == 0;

   // Exactly one ordering between each pair
   // For each pair of aircraft i ≠ j, exactly one order is chosen:
   //   - Either i before j, or j before i.
   forall(i in I, j in I : i < j)
      y[i][j] + y[j][i] == 1;

   // ----------------------
   // Separation constraints (Big-M formulation)
   //
   // If y[i][j] = 1 → i before j -> x[j] ≥ x[i] + s[i][j]
   // If y[i][j] = 0 → j before i -> constraint disabled thanks to the term - M*(1 - y[i][j])
   // ----------------------

   forall(i in I, j in I : i != j) {
      x[j] >= x[i] + s[i][j] - M * (1 - y[i][j]);
   }

}