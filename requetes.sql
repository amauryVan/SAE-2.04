--Exercice 3
--Q1
SELECT n56, n57 + n58 + n59 AS Recalcul FROM import;

--Q2
SELECT n56 FROM import EXCEPT SELECT n57 + n58 + n59 AS Recalcul FROM import;

--Q3
SELECT n74, ROUND((n51/n47)*100) AS Recalcul FROM import WHERE n47 != 0;

--Q4
SELECT n74 FROM import EXCEPT SELECT ROUND((n51/n47)*100) AS Recalcul FROM import WHERE n47 != 0;

--Q5
SELECT n76, ROUND((n53/n47)*100) AS Recalcul FROM import WHERE n47 != 0;

--Q6
SELECT n76, ROUND(CAST(admis_fin_pp AS NUMERIC)/(admis_bg + admis_bt + admis_bp + admis_autres)*100) FROM formation INNER JOIN import ON code_formation = n110 WHERE (admis_bg + admis_bt + admis_bp + admis_autres) != 0;

--Q7
SELECT n81, ROUND((CAST(n55 AS NUMERIC)/n56)*100) AS Recalcul FROM import WHERE n56 != 0;

--Q8
SELECT n81, ROUND(CAST(total_boursiers AS NUMERIC)/admis_neobac*100) FROM formation INNER JOIN import ON code_formation = n110 WHERE admis_neobac != 0;