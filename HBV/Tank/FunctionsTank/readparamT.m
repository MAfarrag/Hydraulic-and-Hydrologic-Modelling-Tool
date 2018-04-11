function [par]=readparamT(path,filename)

format=strsplit(filename,'.');  % split the name from the format to know if it is .m or .cal
if format{2}== 'mat'
    load(path);
    eval(['par=' format{1}]);
else
    fid=fopen(path);
    i=1;
    f = fgetl(fid);
    while f ~= -1
        dummy{i}=strsplit(f);
        f = fgetl(fid);
        varname=dummy{1,i}{1,3};
        varvalue=dummy{1,i}{1,2};
        dummy2=['par' '.' varname '=' varvalue];
        eval(dummy2);
        i=i+1;
    end
end
% i=i-1;
clc

