function FinalMatrix=MatrixCopy(A,n)
[xtemp ytemp]=size(A);
x=xtemp*n;
y=ytemp*n;
temp=zeros(x,y);
for i=1:xtemp
    for j=1:ytemp
        for k=1:n
            for l=1:n
                temp(n*(i-1)+k,n*(j-1)+l)=A(i,j);
            end;
        end;
    end;
end;
FinalMatrix=temp;
end