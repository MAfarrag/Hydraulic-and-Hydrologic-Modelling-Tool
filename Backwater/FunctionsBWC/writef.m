function writef(R,n)
[filename,path] = uiputfile('*.txt','File Selector','write the name of the file');
if (filename~=0)
    path=[path filename];
else
   return
end

fid= fopen(path,'wt');
R=R';
fprintf(fid,['Backwater calculation. Number of points:' num2str(n) '\n']);
fprintf(fid,'%9s   %10s   %7s   %11s   %13s\n','Point No.','Distance X','Depth h','Geo_heights','Piezo_heights');
for i=1:n
fprintf(fid,'%9d   %10d   %7.3f   %11.3f   %13.3f \n',R(i,:));
end 
fclose('all');
