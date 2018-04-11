function [RMSE] = RMSE(Qrec,Qsim)

RMSE = sqrt(mean((Qrec-Qsim).^2));

end
