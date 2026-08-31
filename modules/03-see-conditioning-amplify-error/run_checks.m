function run_checks
%RUN_CHECKS Independent numerical, limiting, and boundary checks for P03.
qStrong = [1;1]/sqrt(2);
qWeak = [1;-1]/sqrt(2);

baseline = model(100,0.001,90);
repeat = model(100,0.001,90);
assert(isequaln(baseline,repeat),'Repeated baseline calls must be deterministic.');
integerInputs = model(uint16(100),0.001,int16(90));
assert(isequaln(baseline,integerInputs), ...
    'Integer-class condition and angle inputs must normalize compatibly.');
singleMinimumInput = model(100,single(1e-6),single(37));
assert(singleMinimumInput.relativeMeasurementError==double(single(1e-6)), ...
    'A single-precision nominal one-ppm boundary must remain accepted.');

expectedMatrix = 0.5*[1+1/100 1-1/100;1-1/100 1+1/100];
assert(max(abs(baseline.systemMatrix(:)-expectedMatrix(:)))<1e-15, ...
    'The transparent calibrated sensor matrix must match its closed form.');
assert(norm(baseline.systemMatrix*qStrong-qStrong)<1e-14, ...
    'The average source direction must have unit gain.');
assert(norm(baseline.systemMatrix*qWeak-qWeak/100)<1e-14, ...
    'The source-difference direction must have gain 1/kappa.');
directDeterminant = baseline.systemMatrix(1,1)*baseline.systemMatrix(2,2) - ...
    baseline.systemMatrix(1,2)*baseline.systemMatrix(2,1);
assert(abs(directDeterminant-1/100)<1e-15, ...
    'The independent 2-by-2 determinant identity must equal 1/kappa.');
directEstimate = solveTwoByTwo(baseline.systemMatrix,baseline.perturbedMeasurement);
assert(norm(directEstimate-baseline.estimatedState)<1e-12, ...
    'Cramer-rule reconstruction must agree with the transparent modal result.');

assert(abs(baseline.relativeInputError-0.001)<1e-14, ...
    'The baseline input error must be 0.1 percent.');
assert(abs(baseline.relativeSolutionError-0.1)<1e-12, ...
    'The baseline source error must be 10 percent.');
assert(abs(baseline.directionalAmplification-100)<1e-12, ...
    'Weak-direction amplification must attain kappa.');
assert(baseline.relativeSolutionError<=baseline.conditionBound+1e-12, ...
    'Source error must respect the condition-number bound.');
assert(abs(baseline.rowSeparationDegrees-2*atand(1/100))<1e-14, ...
    'Sensor-row angle must match the independent geometric identity.');
assert(baseline.relativeResidual<1e-13, ...
    'The baseline estimate must fit the perturbed data closely.');

wellConditionedAngles = [0 37 90];
for i = 1:numel(wellConditionedAngles)
    wellConditioned = model(1,0.001,wellConditionedAngles(i));
    assert(norm(wellConditioned.systemMatrix-eye(2))<1e-14, ...
        'At kappa=1 the calibrated sensor matrix must be the identity.');
    assert(abs(wellConditioned.relativeSolutionError- ...
        wellConditioned.relativeInputError)<1e-13, ...
        'At kappa=1 every perturbation direction must have unit amplification.');
    assert(abs(wellConditioned.directionalAmplification-1)<1e-13, ...
        'The well-conditioned directional amplification must be one.');
end

zeroError = model(100,0,47);
assert(zeroError.relativeInputError==0 && zeroError.relativeSolutionError<1e-14, ...
    'Zero measurement error must preserve the true source.');
assert(norm(zeroError.estimatedState-zeroError.trueState)<1e-14, ...
    'The zero-error estimate must equal the true state within roundoff.');
assert(isfinite(zeroError.directionalAmplification), ...
    'Geometric amplification must stay defined at the zero-error limit.');

minimumError = model(100,1e-6,37);
expectedMinimumSolutionError = ...
    1e-6*minimumError.directionalAmplification;
storedMinimumError = norm(minimumError.perturbedMeasurement- ...
    minimumError.exactMeasurement)/norm(minimumError.exactMeasurement);
assert(minimumError.minimumNonzeroRelativeMeasurementError==1e-6, ...
    'The nonzero input floor must remain one part per million.');
assert(storedMinimumError>0 && abs(storedMinimumError-1e-6)<1e-14, ...
    'The one-ppm nonzero floor must remain visible in stored measurements.');
assert(abs(minimumError.relativeSolutionError-expectedMinimumSolutionError)<1e-12, ...
    'The one-ppm limit must retain the directional amplification relation.');

strongDirection = model(1e6,0.001,0);
assert(abs(strongDirection.directionalAmplification-1)<1e-12, ...
    'Strong-direction amplification must remain one at large kappa.');
assert(abs(strongDirection.relativeSolutionError-0.001)<1e-12, ...
    'A strong-direction error must not receive weak-direction gain.');
sensitiveDirection = model(100,0.001,90);
assert(abs(sensitiveDirection.directionalAmplification-100)<1e-12, ...
    'A weak-direction error must receive the full kappa gain.');
generalDirection = model(100,0.001,37);
assert(generalDirection.directionalAmplification>1 && ...
    generalDirection.directionalAmplification<100, ...
    'An intermediate error direction must realize an intermediate gain.');
assert(generalDirection.relativeSolutionError<=generalDirection.conditionBound+1e-12, ...
    'The general directional error must respect the condition bound.');

conditionValues = [1 3 10 30 100 300 1000];
conditionErrors = zeros(size(conditionValues));
conditionAngles = zeros(size(conditionValues));
for i = 1:numel(conditionValues)
    conditionCase = model(conditionValues(i),0.001,90);
    conditionErrors(i) = conditionCase.relativeSolutionError;
    conditionAngles(i) = conditionCase.rowSeparationDegrees;
end
assert(all(diff(conditionErrors)>0), ...
    'Conditioning sweep source error must grow in the weak direction.');
assert(all(diff(conditionAngles)<0), ...
    'Conditioning sweep sensor-row separation must shrink.');
assert(max(abs(conditionErrors-0.001*conditionValues))<1e-12, ...
    'Conditioning sweep must match the independent worst-direction formula.');

directionAngles = [0 15 30 45 60 75 90];
directionGains = zeros(size(directionAngles));
for i = 1:numel(directionAngles)
    directionCase = model(100,0.001,directionAngles(i));
    directionGains(i) = directionCase.directionalAmplification;
end
expectedDirectionGains = sqrt(cosd(directionAngles).^2 + ...
    100^2*sind(directionAngles).^2);
assert(max(abs(directionGains-expectedDirectionGains))<1e-12, ...
    'Direction sweep must match the independent amplification formula.');
assert(directionGains(1)==1 && abs(directionGains(end)-100)<1e-12, ...
    'Direction sweep must span the strong and weak limiting cases.');

doubledInput = model(100,0.002,90);
assert(abs(doubledInput.relativeSolutionError-2*baseline.relativeSolutionError)<1e-12, ...
    'Doubling input error must double source error in this linear model.');
assert(abs(doubledInput.directionalAmplification-baseline.directionalAmplification)<1e-12, ...
    'Input magnitude must not change directional amplification.');
mirroredDirection = model(100,0.001,-30);
positiveDirection = model(100,0.001,30);
assert(abs(mirroredDirection.relativeSolutionError- ...
    positiveDirection.relativeSolutionError)<1e-12, ...
    'Mirrored error directions must have the same error norm.');
assert(sign(mirroredDirection.parameterErrorCoordinates(2)) == ...
    -sign(positiveDirection.parameterErrorCoordinates(2)), ...
    'Mirroring must reverse the weak error component.');

broken = model(1e6,1e-6,90);
assert(abs(broken.relativeInputError-1e-6)<1e-14, ...
    'The broken input must be one part per million.');
assert(abs(broken.relativeSolutionError-1)<1e-7, ...
    'One-ppm weak-direction error must create order-one source error.');
assert(broken.relativeResidual<1e-12, ...
    'The broken estimate must still fit the perturbed data closely.');
brokenDirect = solveTwoByTwo(broken.systemMatrix,broken.perturbedMeasurement);
assert(norm(brokenDirect-broken.estimatedState)<1e-8, ...
    'Independent direct reconstruction must expose the same broken result.');

bounded = model(1e6,0.01,90);
boundedValues = [bounded.systemMatrix(:);bounded.trueState; ...
    bounded.perturbedMeasurement;bounded.estimatedState;bounded.parameterError; ...
    bounded.relativeInputError;bounded.relativeSolutionError; ...
    bounded.directionalAmplification;bounded.conditionBound; ...
    bounded.rowSeparationDegrees;bounded.relativeResidual];
assert(all(isfinite(boundedValues)), ...
    'The maximum supported fixed-size calculation must remain finite.');
assert(isequal(size(bounded.systemMatrix),[2 2]) && ...
    isequal(size(bounded.estimatedState),[2 1]), ...
    'The model resource footprint must remain fixed at two channels.');
assert(bounded.relativeSolutionError<=bounded.conditionBound+1e-8, ...
    'The maximum supported case must respect the condition bound.');

expectFailure(@() model([10 100],0.001,90),'Vector kappa must be rejected.');
expectFailure(@() model(10+1i,0.001,90),'Complex kappa must be rejected.');
expectFailure(@() model(NaN,0.001,90),'NaN kappa must be rejected.');
expectFailure(@() model(Inf,0.001,90),'Infinite kappa must be rejected.');
expectFailure(@() model(0.99,0.001,90),'Below-bound kappa must be rejected.');
expectFailure(@() model(1e6+1,0.001,90),'Above-bound kappa must be rejected.');
expectFailure(@() model('large',0.001,90),'Text kappa must be rejected.');
expectFailure(@() model(100,[0.001 0.002],90),'Vector error must be rejected.');
expectFailure(@() model(100,0.001+1i,90),'Complex error must be rejected.');
expectFailure(@() model(100,NaN,90),'NaN error must be rejected.');
expectFailure(@() model(100,Inf,90),'Infinite error must be rejected.');
expectFailure(@() model(100,-eps,90),'Negative error must be rejected.');
expectFailure(@() model(100,0.5e-6,90), ...
    'A positive error below one ppm must be rejected.');
expectFailure(@() model(100,0.010001,90),'Above-bound error must be rejected.');
expectFailure(@() model(100,'small',90),'Text error must be rejected.');
expectFailure(@() model(100,0.001,[0 90]),'Vector angle must be rejected.');
expectFailure(@() model(100,0.001,1i),'Complex angle must be rejected.');
expectFailure(@() model(100,0.001,NaN),'NaN angle must be rejected.');
expectFailure(@() model(100,0.001,Inf),'Infinite angle must be rejected.');
expectFailure(@() model(100,0.001,-90.01),'Below-bound angle must be rejected.');
expectFailure(@() model(100,0.001,90.01),'Above-bound angle must be rejected.');
expectFailure(@() model(100,0.001,'weak'),'Text angle must be rejected.');

recovered = model(100,0.001,90);
assert(isequaln(recovered,baseline), ...
    'A rejected call must not contaminate a later valid calculation.');
disp('P03 checks passed.');
end

function estimate = solveTwoByTwo(matrix,rightHandSide)
%SOLVETWOBYTWO Independent Cramer-rule oracle for the fixed-size model.
determinant = matrix(1,1)*matrix(2,2)-matrix(1,2)*matrix(2,1);
assert(determinant~=0,'Independent direct solve requires a nonsingular matrix.');
estimate = [ ...
    matrix(2,2)*rightHandSide(1)-matrix(1,2)*rightHandSide(2); ...
    -matrix(2,1)*rightHandSide(1)+matrix(1,1)*rightHandSide(2)]/determinant;
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
