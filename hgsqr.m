function [Q,R,piv,k] = hgsqr(A,tol)
% Authors:
% Matthew Reynolds
% David Biagioni
%
% This is a hacked version of dgsqr, where we use the SVD to get k
%
% inputs:
% A - input matrix
% tol - tolerance for pivoting, exiting program
%
% outputs:
% Q - orthogonal matrix
% R - Upper Triangular matrix, A = QR
% piv - vector keeping track of the pivots
% k - number of pivots made

% Compute the norm of A used for termination of the algorithm
nA = norm(A);

% Take the svd of the matrix
[~,sv,~] = svd(A);
sv = diag(sv);
maxrnk = length(sv(sv/sv(1) > tol));

% Initialize matrices and parameters used in the code
[m,n] = size(A);
%maxrnk = min(m,n);
Q = zeros(m,maxrnk);
R = zeros(maxrnk,n);
CGScoeff = zeros(maxrnk,1);

% Find the first pivot
piv = 1:n;
c = sqrt(sum(A.^2,1));
[~,imax] = max(c);
imax = imax(1);

% Perform the first pivot
tmp = piv(1);  piv(1) = piv(imax);  piv(imax) = tmp;
tmp = A(:,1);  A(:,1) = A(:,imax);  A(:,imax) = tmp;
tmp = c(1);    c(1) = c(imax);      c(imax) = tmp;

% MGS sweep for the first column of A
R(1,1) = norm(A(:,1));
Q(:,1) = A(:,1) / R(1,1);
R(1,2:n) = Q(:,1)' * A(:,2:n);
for j = 2:n
    A(:,j) = A(:,j) - R(1,j) * Q(:,1);
end

% If the matrix has max rank 1, return values
if maxrnk == 1
    Q = Q(:,1);
    R = R(1,:);
    k = 1;
    return 
end

% find second pivot
c(2:n) = sqrt(sum(A(2:m,2:n).^2,1));
[~,imax] = max(c(2:n));
imax = imax(1);  imax = 1 + imax(1);

% check for convergence
% if abs(cmax) < tol
% if norm(A(2:m,2:n)) <= tol*nA % termination cond from Golub and VanLoan
%     Q = Q(:,1);
%     R = R(1,:);
%     k = 1;
%     return
% end

% Double MGS iterations
for k = 2:maxrnk
    
    % perform pivot
    tmp = piv(k);  piv(k) = piv(imax);  piv(imax) = tmp;
    tmp = A(:,k);  A(:,k) = A(:,imax);  A(:,imax) = tmp;
    tmp = R(:,k);  R(:,k) = R(:,imax);  R(:,imax) = tmp;
    tmp = c(k);    c(k) = c(imax);      c(imax) = tmp;
    
    % First we compute the CGS step and compute Q and diagonal value of R
    CGScoeff(1:k-1) = Q(:,1:k-1)'*A(:,k);
    z = A(:,k)-Q(:,1:k-1)*CGScoeff(1:k-1);
    R(k,k) = norm(z);
    Q(:,k) = z/R(k,k);
    
    % Now we do the orthogonalization from MGS
    R(k,(k+1):n) = Q(:,k)' * A(:,(k+1):n);
    for j = (k+1):n
      A(:,j) = A(:,j) - R(k,j) * Q(:,k);
    end
    
    % find next pivot
    if k < maxrnk
        % Truncate the vectors we look at each time as well...
        c((k+1):n) = sqrt(sum(A((k+1):m,(k+1):n).^2,1)); % relating tol to actual norms?
        %c((k+1):n) = sqrt(c((k+1):n) - R(k,(k+1):n).^2);
        [~,imax] = max(c((k+1):n));
        imax = imax(1);  imax = k + imax(1);
    end
    
    % check for convergence
    %if abs(cmax) < tol
%     if norm(A((k+1):m,(k+1):n)) <=tol*nA % termination cond from Golub and VanLoan
%         Q = Q(:,1:k);
%         R = R(1:k,:);
%         return
%     end
end


end
