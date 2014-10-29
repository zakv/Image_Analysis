function matrixBinning=Binning(A,n)
[xtemp ytemp]=size(A);
x=floor(xtemp/n);
y=floor(ytemp/n);
temp=zeros(x,y);
for i=1:x
    for j=1:y
        part=A(n*(i-1)+1:n*i,n*(j-1)+1:n*j);
        temp(i,j)=mean(part(:));
    end;
end;
matrixBinning=temp;
end