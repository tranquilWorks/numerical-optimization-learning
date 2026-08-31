function interactive
%INTERACTIVE Bounded controls for the P03 conditioning experiment.
baselineConditionExponent = 2; % kappa_2 = 100
baselineErrorPpm = 1000;       % 0.1 percent
baselineErrorAngle = 90;
modelFcn = @model; % Preserve the P03 model after launch_lesson removes its path.

fig = uifigure('Name','P03 Conditioning Amplifies Error', ...
    'Position',[100 100 1120 720]);
gridLayout = uigridlayout(fig,[5 4]);
gridLayout.RowHeight = {'1x','1x',92,22,38};
gridLayout.ColumnWidth = {'1x','1x','1x',130};

rowAxes = uiaxes(gridLayout);
rowAxes.Layout.Row = [1 2];
rowAxes.Layout.Column = [1 2];
stateAxes = uiaxes(gridLayout);
stateAxes.Layout.Row = [1 2];
stateAxes.Layout.Column = [3 4];

summary = uilabel(gridLayout);
summary.Layout.Row = 3;
summary.Layout.Column = [1 4];

conditionLabel = uilabel(gridLayout,'Text','Condition exponent: \kappa_2 = 10^p');
conditionLabel.Layout.Row = 4;
conditionLabel.Layout.Column = 1;
errorLabel = uilabel(gridLayout,'Text','Measurement error (ppm)');
errorLabel.Layout.Row = 4;
errorLabel.Layout.Column = 2;
angleLabel = uilabel(gridLayout,'Text','Error angle toward weak direction (degrees)');
angleLabel.Layout.Row = 4;
angleLabel.Layout.Column = 3;

conditionExponent = uislider(gridLayout,'Limits',[0 6], ...
    'MajorTicks',0:6,'Value',baselineConditionExponent);
conditionExponent.Layout.Row = 5;
conditionExponent.Layout.Column = 1;
errorPpm = uispinner(gridLayout,'Limits',[0 10000],'Step',100, ...
    'RoundFractionalValues','on','Value',baselineErrorPpm);
errorPpm.Layout.Row = 5;
errorPpm.Layout.Column = 2;
errorAngle = uislider(gridLayout,'Limits',[0 90], ...
    'MajorTicks',[0 15 30 45 60 75 90],'Value',baselineErrorAngle);
errorAngle.Layout.Row = 5;
errorAngle.Layout.Column = 3;
resetButton = uibutton(gridLayout,'Text','Reset baseline');
resetButton.Layout.Row = 5;
resetButton.Layout.Column = 4;

conditionExponent.ValueChangedFcn = @(~,~) updatePlots();
errorPpm.ValueChangedFcn = @(~,~) updatePlots();
errorAngle.ValueChangedFcn = @(~,~) updatePlots();
resetButton.ButtonPushedFcn = @(~,~) resetBaseline();
updatePlots();

    function resetBaseline
        conditionExponent.Value = baselineConditionExponent;
        errorPpm.Value = baselineErrorPpm;
        errorAngle.Value = baselineErrorAngle;
        updatePlots();
    end

    function updatePlots
        conditionNumber = 10^conditionExponent.Value;
        relativeError = round(errorPpm.Value)*1e-6;
        angleDegrees = errorAngle.Value;
        out = modelFcn(conditionNumber,relativeError,angleDegrees);

        cla(rowAxes);
        plot(rowAxes,[0 out.systemMatrix(1,1)],[0 out.systemMatrix(1,2)], ...
            'o-','LineWidth',1.6,'DisplayName','Sensor row 1');
        hold(rowAxes,'on');
        plot(rowAxes,[0 out.systemMatrix(2,1)],[0 out.systemMatrix(2,2)], ...
            's-','LineWidth',1.6,'DisplayName','Sensor row 2');
        hold(rowAxes,'off'); grid(rowAxes,'on'); axis(rowAxes,'equal');
        xlabel(rowAxes,'Source 1 sensitivity (sensor units / source unit)');
        ylabel(rowAxes,'Source 2 sensitivity (sensor units / source unit)');
        title(rowAxes,sprintf('Sensor-row separation %.5g degrees', ...
            out.rowSeparationDegrees));
        legend(rowAxes,'Location','best');

        cla(stateAxes);
        plot(stateAxes,[0 out.trueState(1)],[0 out.trueState(2)], ...
            'o-','LineWidth',1.8,'DisplayName','True source');
        hold(stateAxes,'on');
        plot(stateAxes,[0 out.estimatedState(1)],[0 out.estimatedState(2)], ...
            's-','LineWidth',1.8,'DisplayName','Inferred source');
        hold(stateAxes,'off'); grid(stateAxes,'on'); axis(stateAxes,'equal');
        xlabel(stateAxes,'Source component 1 (source units)');
        ylabel(stateAxes,'Source component 2 (source units)');
        title(stateAxes,'Conditioned inference error');
        legend(stateAxes,'Location','best');

        summary.Text = sprintf([ ...
            '\\kappa_2 %.5g | row angle %.5g degrees | input %.6g%% (%d ppm) | ' ...
            'source error %.6g%%\n' ...
            'directional amplification %.6g | worst-case bound %.6g%% | ' ...
            'perturbed-data residual %.3e'], ...
            out.conditionNumber,out.rowSeparationDegrees,out.inputErrorPercent, ...
            round(errorPpm.Value),out.solutionErrorPercent, ...
            out.directionalAmplification,out.conditionBoundPercent, ...
            out.relativeResidual);
    end
end
