/*********************************************
 * OPL 22.1.2.0 Model
 * Author: adrien.dacostaveiga
 * Creation Date: Mar 3, 2026 at 10:51:51 AM
 *********************************************/

// =====================================================
// AIRCRAFT LANDING PROBLEM - PROBLEM 3
// Minimizing Total Lateness with Runway Assignment
// Multiple Runway Version
// =====================================================


// ======================
// SETS
// ======================

int n = ...;               // number of aircraft
int m = ...;               // number of runways

range I = 1..n;
range R = 1..m;


// ======================
// PARAMETERS
// ======================

float E[I] = ...;          // Earliest landing times
float L[I] = ...;          // Latest landing times
float A[I] = ...;          // Latest arrival time at gate

float s[I][I] = ...;       // Separation times
float t[I][R] = ...;       // Taxi time to gate from runway r

float M = ...;             // Big-M constant


// ======================
// DECISION VARIABLES
// ======================

dvar float+ x[I];          // Landing times

dvar boolean y[I][R];      // Runway assignment
dvar boolean z[I][I];      // Ordering variables

dvar float+ Late[I];       // Lateness at gate


// ======================
// OBJECTIVE FUNCTION
//
// Minimize total lateness
// ======================

minimize
   sum(i in I) Late[i];


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
   // Each aircraft assigned to exactly one runway
   // ----------------------
   forall(i in I)
      sum(r in R) y[i][r] == 1;

   // ----------------------
   // Ordering consistency
   // ----------------------

   forall(i in I)
      z[i][i] == 0;

   forall(i in I, j in I : i < j)
      z[i][j] + z[j][i] == 1;

   // ----------------------
   // Separation constraints
   // Only if aircraft use same runway
   // ----------------------

   forall(i in I, j in I : i < j) {

      // If i before j AND same runway
      x[j] >= x[i] + s[i][j]
              - M * (1 - z[i][j])
              - M * (2 - sum(r in R)(y[i][r] + y[j][r] - 1));

      // If j before i AND same runway
      x[i] >= x[j] + s[j][i]
              - M * (1 - z[j][i])
              - M * (2 - sum(r in R)(y[i][r] + y[j][r] - 1));
   }

   // ----------------------
   // Lateness definition
   //
   // Arrival time at gate = x[i] + taxi time
   // ----------------------

   forall(i in I) {
      Late[i] >= x[i] + sum(r in R)(t[i][r] * y[i][r]) - A[i];
      Late[i] >= 0;
   }
}