Set T /h0*h24/
baset (t) heure /h0/
T2 /h2*h24/;
Parameters
    q(t) débit en amont horaire
         /h1 34, h2 37, h3 54, h4 67, h5 79, h6 35, h7 97, h8 119, h9 136, h10 93,
          h11 96, h12 83, h13 152, h14 53, h15 58, h16 47, h17 38, h18 64, h19 101,
          h20 102, h21 68, h22 43, h23 59, h24 57/ 
    p(t) prix de l'électricité horaire
         /h1 29, h2 23, h3 19, h4 17, h5 29, h6 34, 
          h7 76, h8 102, h9 73, h10 77, h11 67, h12 59, 
          h13 55, h14 75, h15 75, h16 100, h17 95, h18 100,
          h19 73, h20 41, h21 35, h22 33, h23 36, h24 30/;
          
Scalar
          
    QtAmont_min Minimum dans le réservoir Amont /500000/,
    QtAmont_max Maximum réservoir Amont /8000000/,
    QtAval_min Minimum réservoir aval /200000/,
    QtAval_max Maximum réservoir aval /4000000/,
    r_max Quantité max puissance turbine /500000/,
    e capacité de production de la turbine /0.0001/,
    QtAmont_start Quantité initiale en amont /4000000/,
    QtAval_start Quantité initale en aval /3500000/,
    f Consommation de la pompe /0.00013/,
    m_max débit max de la pompe /720000/;
*-------------------------------------------------------------------------------
Variable
AmontQt(t) volume amont à la fin du temps t,
AvalQt(t) volume aval à la fin du temps t,
D(t) Eau perdue en aval,
Turbinage(t) Eau passant par la turbine,
Delestage(t) délestage,
Pompage(t) Eau passant par la pompe,
OBJ Objective (revenue);

Positive Variable
AmontQt, AvalQt, D, Turbinage, Delestage, Pompage;

AmontQt.lo(t) = QtAmont_min;
AmontQt.up(t) = QtAmont_max;
AmontQt.fx(baset) = QtAmont_start;
AvalQt.lo(t) = QtAval_min;
AvalQt.up(t) = QtAval_max;
AvalQt.fx(baset) = QtAval_start;
AmontQt.fx('h24')=Qtamont_start;
AvalQt.fx('h24')=QtAval_start;

*-------------------------------------------------------------------------------
equations
levelAmont(t) Niveau du réservoir Amont fin de période
levelAval(t) Niveau du réservoir aval en fin de période
VarTurb1(t) Variation 1
VarTurb2 (t) Variation 2
VarDel1(t) Variation 1
VarDel2 (t) Variation 2

objdef Definition of revenue;

levelAmont(t+1).. AmontQt(t+1) =e= AmontQt(t) + q(t+1)*3600 + Pompage(t+1) - Turbinage(t+1) - Delestage(t+1);

levelAval(t+1).. AvalQt(t+1) =e= AvalQt(t) + Turbinage(t+1) + Delestage(t+1) - D(t+1) - Pompage(t+1);

VarTurb1(t)$T2(t).. Turbinage(t) - Turbinage (t-1) =l= 80*3600;
VarTurb2(t)$T2(t).. Turbinage(t-1) - Turbinage (t) =l= 80*3600;

VarDel1(t)$T2(t).. Delestage(t) - Delestage (t-1) =l= 80*3600;
VarDel2(t)$T2(t).. Delestage(t-1) - Delestage (t) =l= 80*3600;


objdef.. OBJ =e= sum(t, p(t)*Turbinage(t)* e) - sum(t, p(t)*Pompage(t)*f);


Turbinage.lo(t) = 0;
Turbinage.up(t) = r_max;
Delestage.lo(t) = 0;
D.lo(t) = 36000;
Pompage.lo(t) = 0;
Pompage.up(t) = m_max;
*-------------------------------------------------------------------------------
model waterplanning /All/;
solve waterplanning using lp maximizing OBJ;