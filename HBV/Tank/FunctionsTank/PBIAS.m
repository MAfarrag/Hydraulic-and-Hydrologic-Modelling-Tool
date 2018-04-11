function [PBIAS] = PBIAS(Qrec,Qsim)
 
PBIAS_1 = sum((Qrec-Qsim)*100);
PBIAS_2 = sum(Qrec);

PBIAS = PBIAS_1/PBIAS_2;

end