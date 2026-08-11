function out = model(alpha,condition,startScale,iterations)
%MODEL Gradient descent on a two-dimensional quadratic.
arguments
    alpha (1,1) double {mustBePositive} = 0.08
    condition (1,1) double {mustBeGreaterThanOrEqual(condition,1)} = 10
    startScale (1,1) double {mustBePositive} = 4
    iterations (1,1) double {mustBeInteger,mustBePositive} = 60
end
Q=diag([1 condition]);
x=zeros(2,iterations+1);
x(:,1)=[startScale; startScale];
f=zeros(1,iterations+1);
f(1)=0.5*x(:,1)'*Q*x(:,1);
for k=1:iterations
    grad=Q*x(:,k);
    x(:,k+1)=x(:,k)-alpha*grad;
    f(k+1)=0.5*x(:,k+1)'*Q*x(:,k+1);
end
lim=max(1.2*startScale,2);
[x1,x2]=meshgrid(linspace(-lim,lim,180));
surface=0.5*(x1.^2+condition*x2.^2);
out=struct('x',x,'f',f,'x1',x1,'x2',x2,'surface',surface, ...
    'alpha',alpha,'condition',condition,'spectralRadius',max(abs(1-alpha*[1 condition])), ...
    'converged',all(isfinite(f)) && f(end)<f(1)*1e-4);
end
