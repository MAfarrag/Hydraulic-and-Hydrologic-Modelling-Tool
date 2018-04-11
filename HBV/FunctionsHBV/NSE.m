function [Obj] = NSE(Qrec,Qsim)

a = sum((Qsim - Qrec).^2);
b = sum((Qrec - mean(Qrec)).^2);

Obj = 1-a/b;

end
