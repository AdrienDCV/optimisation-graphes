/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:39:04 AM
 *********************************************/

 // =====================================================
// AIRCRAFT LANDING PROBLEM - PROBLEM 2
// Minimizing Makespan
// Single Runway Version
// =====================================================


// ======================
// SETS
// ======================

int n = ...;
range I = 1..n;


// ======================
// PARAMETERS
// ======================

float E[I] = ...;          // Earliest landing times
float L[I] = ...;          // Latest landing times
float s[I][I] = ...;       // Separation time matrix

float M = ...;             // Big-M constant


// ======================
// DECISION VARIABLES
// ======================

dvar float+ x[I];          // Landing times
dvar boolean y[I][I];      // Ordering variables
dvar float+ Cmax;          // Makespan


// ======================
// OBJECTIVE FUNCTION
//
// Minimize landing time of last aircraft
// ======================

minimize Cmax;


// ======================
// CONSTRAINTS
// ======================

subject to {

   // ----------------------
   // Time windows
   // ----------------------
   forall(i in I)
      E[i] <= x[i] <= L[i];

   // ----------------------
   // Makespan definition
   // Cmax ≥ x[i] for all i
   // ----------------------
   forall(i in I)
      x[i] <= Cmax;

   // ----------------------
   // Ordering constraints
   // ----------------------

   // No self-ordering
   forall(i in I)
      y[i][i] == 0;

   // Exactly one ordering per pair
   forall(i in I, j in I : i < j)
      y[i][j] + y[j][i] == 1;

   // ----------------------
   // Separation constraints
   // ----------------------
   forall(i in I, j in I : i < j) {

      // If i before j
      x[j] >= x[i] + s[i][j] - M * (1 - y[i][j]);

      // If j before i
      x[i] >= x[j] + s[j][i] - M * (1 - y[j][i]);
   }
}