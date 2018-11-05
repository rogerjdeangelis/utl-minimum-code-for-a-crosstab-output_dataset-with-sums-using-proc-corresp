Minimum code for a output crosstab sas dataset with sums using proc corresp

I find it more usefull to have an output dataset rather than
a static listing output.

This question shows the flexibility of a normalized form.

You can create a crosstab output dataset four ways using the normalized form

   1. proc corresp (least code)  ** only one presented
   2. proc transpose and datastep to sum
   3. proc report with out= option
   4. SQL with do_over arrays


see SAS Forum
https://tinyurl.com/yc2wj2tr
https://communities.sas.com/t5/SAS-Procedures/Help-determining-frequency-of-coded-entries-within-variables/m-p/510218

Stole pieces of code from K Sharp
https://communities.sas.com/t5/user/viewprofilepage/user-id/18408


HAVE
====

WORK.HAVE total obs=5

  PATIENT    YEAR    CODES

     1        18     0123;4444;2346;0912
     2        17     1234;4444
     3        17     0912
     4        16     0123;2346;0912
     5        15     4444


RULES (first normalize then pivot)

 WORK.HAVNRM total obs=11

  YEAR    CODE    CNT

   18     0123     1
   18     4444     1
   18     2346     1
   18     0912     1
   17     1234     1
   17     4444     1
   17     0912     1
   16     0123     1
   16     2346     1
   16     0912     1
   15     4444     1


EXAMPLE OUTPUT
--------------

WORK.WANT total obs=6

  LABEL    _15    _16    _17    _18      SUM

  0123      0      1      0      1         2
  0912      0      1      1      1         3
  1234      0      0      1      0         1
  2346      0      1      0      1         2
  4444      1      0      1      1         3

  Sum       1      3      3      4        11


PROCESS
=======

* normalize;

data havNrm;
 set have;
 do i=1 to countw(Codes,';');
   code=scan(Codes,i,';');
   output;
 end;
 retain cnt 1;
 drop i codes patient;
run;


ods output observed=want;
proc corresp data=havNxt dim=1 observed;
table code, year;
run;quit;


MAKE DATA
=========

data have;
input Patient Year Codes $40.;
cards4;
1 18 0123;4444;2346;0912
2 17 1234;4444
3 17 0912
4 16 0123;2346;0912
5 15 4444
;;;;
run;

