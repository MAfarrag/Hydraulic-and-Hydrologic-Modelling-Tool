function [par]=readparamf(path)
fid=fopen(path);
i=1;
f = fgetl(fid);
while f ~= -1
    dummy{i}=strsplit(f);
    f = fgetl(fid);
    varname=dummy{1,i}{1,2};
    varvalue=dummy{1,i}{1,1};
    dummy2=['par' '.' varname '=' varvalue];
    eval(dummy2);
    i=i+1;
end
i=i-1;

