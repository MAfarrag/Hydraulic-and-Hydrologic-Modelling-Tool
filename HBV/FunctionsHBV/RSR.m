function [RSR] = RSR(Qrec,Qsim)

RMSE_1 = sqrt(sum((Qrec-Qsim).^2));
STDEV = sqrt(sum((Qrec-mean(Qrec)).^2));

RSR = RMSE_1/STDEV;

end