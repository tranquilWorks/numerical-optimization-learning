function run_checks
%RUN_CHECKS Independent numerical and boundary checks for P02.
spacing = 2^-23; % Analytical spacing for normalized single values in [1,2).
assert(double(eps(single(1)))==spacing, ...
    'Independent IEEE single-spacing identity should hold at one.');

baseline = model(1,3*2^-25,64);
repeat = model(1,3*2^-25,64);
assert(isequaln(baseline,repeat),'Repeated baseline calls must be deterministic.');
integerCount = model(1,3*2^-25,uint16(64));
assert(isequaln(baseline,integerCount), ...
    'Integer-class counts must normalize to the same bounded calculation.');
assert(baseline.spacingAtStart==spacing,'Model spacing must match the independent identity.');
assert(baseline.changedSteps==64,'Every 0.75-ULP baseline update should change storage.');
assert(baseline.observedChange==64*spacing, ...
    'Each baseline update should round to one ULP.');
assert(baseline.expectedChange==48*spacing, ...
    'The analytical baseline change should be 48 ULPs.');
assert(baseline.finalError==16*spacing && baseline.finalErrorInUlps==16, ...
    'The baseline should accumulate exactly +16 starting ULPs of error.');
assert(all(abs(baseline.stepRoundoff)<=0.5*spacing), ...
    'Same-binade operation error must stay within half a local ULP.');

zeroSteps = model(1,2^-20,0);
assert(isequal(zeroSteps.storedValue,1) && zeroSteps.finalError==0, ...
    'Zero additions must preserve the start exactly.');
assert(isempty(zeroSteps.stepRoundoff),'Zero additions must have no per-step errors.');
zeroUpdate = model(1,0,64);
assert(all(zeroUpdate.storedValue==1) && zeroUpdate.finalError==0, ...
    'A zero update must preserve a constant trace.');

exact = model(1,2^-20,64); % Eight ULPs per addition.
assert(exact.changedSteps==64 && all(exact.cumulativeError==0), ...
    'An exactly representable update should accumulate without error.');
absorbed = model(1,2^-25,64); % One quarter ULP per addition.
assert(absorbed.changedSteps==0 && absorbed.stepwiseFinal==1, ...
    'A sub-half-ULP update should be absorbed at every ordered step.');

smallAccumulator = model(0.25,3*2^-25,64);
largeAccumulator = model(4,3*2^-25,64);
assert(smallAccumulator.incrementInUlps==3 && smallAccumulator.finalError==0, ...
    'The fixed update should be exact at the small accumulator.');
assert(largeAccumulator.incrementInUlps<0.5 && largeAccumulator.changedSteps==0, ...
    'The same update should be absorbed when magnitude enlarges spacing.');

broken = model(1,2^-25,1024);
assert(broken.changedSteps==0,'The broken ordered calculation should stagnate.');
assert(broken.roundedOnceFinal==1+256*spacing, ...
    'The independently grouped update should move by 256 ULPs.');
assert(broken.roundedOnceFinal>broken.stepwiseFinal, ...
    'Ordered and grouped additions must expose grouping failure.');

tinyUpdate = model(2^20,2^-40,1);
assert(tinyUpdate.expectedChange==2^-40 && tinyUpdate.observedChange==0, ...
    'Change coordinates must retain an update below double spacing at the start.');
assert(tinyUpdate.finalError==-2^-40, ...
    'An absorbed tiny update must retain its negative analytical error.');

bounded = model(2^-20,2^20,10000);
assert(numel(bounded.step)==10001 && ...
    all(isfinite([bounded.storedValue bounded.referenceChange ...
    bounded.observedChangeHistory bounded.cumulativeError])) && ...
    all(isfinite([bounded.expectedChange bounded.observedChange bounded.finalError])), ...
    'The maximum supported calculation must remain finite and bounded.');
assert(bounded.finalError==-2^-20, ...
    'Recursive step error must retain a tiny lost start after a huge accumulated change.');

expectFailure(@() model([1 2],2^-25,1),'Vector start must be rejected.');
expectFailure(@() model(1+1i,2^-25,1),'Complex start must be rejected.');
expectFailure(@() model(NaN,2^-25,1),'NaN start must be rejected.');
expectFailure(@() model(Inf,2^-25,1),'Infinite start must be rejected.');
expectFailure(@() model(0,2^-25,1),'Out-of-range start must be rejected.');
expectFailure(@() model(2^-21,2^-25,1),'Below-bound start must be rejected.');
expectFailure(@() model(2^21,2^-25,1),'Above-bound start must be rejected.');
expectFailure(@() model(1,-2^-25,1),'Negative update must be rejected.');
expectFailure(@() model(1,[2^-25 2^-24],1),'Vector update must be rejected.');
expectFailure(@() model(1,NaN,1),'NaN update must be rejected.');
expectFailure(@() model(1,Inf,1),'Infinite update must be rejected.');
expectFailure(@() model(1,2^21,1),'Above-bound update must be rejected.');
expectFailure(@() model(1,2^-25,1.5),'Fractional count must be rejected.');
expectFailure(@() model(1,2^-25,-1),'Negative count must be rejected.');
expectFailure(@() model(1,2^-25,[1 2]),'Vector count must be rejected.');
expectFailure(@() model(1,2^-25,NaN),'NaN count must be rejected.');
expectFailure(@() model(1,2^-25,Inf),'Infinite count must be rejected.');
expectFailure(@() model(1,2^-25,10001),'Over-bound count must be rejected.');
expectFailure(@() model('one',2^-25,1),'Text input must be rejected.');

recovered = model(1,3*2^-25,64);
assert(isequaln(recovered,baseline), ...
    'A rejected call must not contaminate a later valid calculation.');
disp('P02 checks passed.');
end

function expectFailure(action,message)
didFail = false;
try
    action();
catch
    didFail = true;
end
assert(didFail,message);
end
