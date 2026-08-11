function run_checks
a=model(0.05,10,4,100);
assert(a.f(end)<a.f(1),'Stable baseline should reduce objective.');
assert(a.spectralRadius<1,'Baseline iteration matrix should be stable.');
b=model(0.25,10,4,20);
assert(b.spectralRadius>1,'Broken case must be unstable.');
c=model(0.05,1,4,40);
d=model(0.05,50,4,40);
assert(d.f(end)>c.f(end),'Poor conditioning should converge more slowly for this setup.');
disp('P01 checks passed.');
end
