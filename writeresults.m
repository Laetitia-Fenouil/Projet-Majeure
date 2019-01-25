function filename = writeresults(A, F, B, BPM, V, file, path, dT)
A = A*100;
N = length(B);

filename = strrep(file, '.', '_');
filename = strrep(filename,' ', '_');
filename = strcat(filename, '_song_properties.txt');

if(~exist(filename, 'file'))
    fileID = fopen(filename,'w');
    fprintf(fileID, strcat('file:',path, file,'\n'));
    fprintf(fileID, strcat('Dt:',num2str(dT),'\n'));
    fprintf(fileID, strcat('NSample:',num2str(N),'\n\n'));
    
    fprintf(fileID, strcat('BPM:',num2str(BPM),'\n'));
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(F(i,1)));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('F1:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(A(i,1),'%f'));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('A1:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(F(i,2)));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('F2:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(A(i,2),'%f'));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('A2:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(F(i,3)));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('F3:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(A(i,3),'%f'));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('A3:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(B(i),'%f'));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('B:', stringvalue,'\n'));
    
    stringvalue = '';
    for i=1:N
        stringvalue = strcat(stringvalue,num2str(V(i),'%f'));
        if(i<N)
            stringvalue = strcat(stringvalue,'-');
        end
    end
    fprintf(fileID, strcat('V:', stringvalue,'\n'));

    
    fclose(fileID)
end
end