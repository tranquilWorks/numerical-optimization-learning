function interactive
%INTERACTIVE Bounded controls for the P02 single-precision accumulator.
baselineStartExponent = 0;
baselineUpdateUlpsAtOne = 0.75;
baselineAdditions = 64;
modelFcn = @model; % Preserve the P02 model after launch_lesson removes its path.

fig = uifigure('Name','P02 Floating-Point Roundoff','Position',[100 100 1120 720]);
gridLayout = uigridlayout(fig,[5 4]);
gridLayout.RowHeight = {'1x','1x',82,22,38};
gridLayout.ColumnWidth = {'1x','1x','1x',120};

traceAxes = uiaxes(gridLayout);
traceAxes.Layout.Row = [1 2];
traceAxes.Layout.Column = [1 2];
errorAxes = uiaxes(gridLayout);
errorAxes.Layout.Row = [1 2];
errorAxes.Layout.Column = [3 4];

summary = uilabel(gridLayout);
summary.Layout.Row = 3;
summary.Layout.Column = [1 4];

startLabel = uilabel(gridLayout,'Text','Start exponent m: x_0 = 2^m');
startLabel.Layout.Row = 4;
startLabel.Layout.Column = 1;
updateLabel = uilabel(gridLayout,'Text','Update size at x=1 (ULP)');
updateLabel.Layout.Row = 4;
updateLabel.Layout.Column = 2;
countLabel = uilabel(gridLayout,'Text','Ordered additions');
countLabel.Layout.Row = 4;
countLabel.Layout.Column = 3;

startExponent = uispinner(gridLayout,'Limits',[-2 4],'Step',1, ...
    'RoundFractionalValues','on','Value',baselineStartExponent);
startExponent.Layout.Row = 5;
startExponent.Layout.Column = 1;
updateUlpsAtOne = uislider(gridLayout,'Limits',[0.1 2], ...
    'MajorTicks',[0.1 0.25 0.5 0.75 1 1.25 1.5 1.75 2], ...
    'Value',baselineUpdateUlpsAtOne);
updateUlpsAtOne.Layout.Row = 5;
updateUlpsAtOne.Layout.Column = 2;
additionCount = uispinner(gridLayout,'Limits',[0 4096],'Step',1, ...
    'RoundFractionalValues','on','Value',baselineAdditions);
additionCount.Layout.Row = 5;
additionCount.Layout.Column = 3;
resetButton = uibutton(gridLayout,'Text','Reset baseline');
resetButton.Layout.Row = 5;
resetButton.Layout.Column = 4;

startExponent.ValueChangedFcn = @(~,~) updatePlots();
updateUlpsAtOne.ValueChangedFcn = @(~,~) updatePlots();
additionCount.ValueChangedFcn = @(~,~) updatePlots();
resetButton.ButtonPushedFcn = @(~,~) resetBaseline();
updatePlots();

    function resetBaseline
        startExponent.Value = baselineStartExponent;
        updateUlpsAtOne.Value = baselineUpdateUlpsAtOne;
        additionCount.Value = baselineAdditions;
        updatePlots();
    end

    function updatePlots
        startValue = 2^round(startExponent.Value);
        increment = updateUlpsAtOne.Value*double(eps(single(1)));
        additions = round(additionCount.Value);
        out = modelFcn(startValue,increment,additions);

        cla(traceAxes);
        plot(traceAxes,out.step,out.referenceChange,'--', ...
            'LineWidth',1.5,'DisplayName','Analytical reference');
        hold(traceAxes,'on');
        plot(traceAxes,out.step,out.observedChangeHistory,'o-', ...
            'LineWidth',1.1,'MarkerSize',3,'DisplayName','Stored single result');
        hold(traceAxes,'off'); grid(traceAxes,'on');
        xlabel(traceAxes,'Addition count');
        ylabel(traceAxes,'Accumulated change (value units)');
        title(traceAxes,'Stored change versus reference');
        legend(traceAxes,'Location','best');

        cla(errorAxes);
        plot(errorAxes,out.step,out.errorInStartUlps,'LineWidth',1.5);
        grid(errorAxes,'on');
        xlabel(errorAxes,'Addition count');
        ylabel(errorAxes,'Signed error (starting-point ULP)');
        title(errorAxes,'Roundoff history');

        summary.Text = sprintf([ ...
            'single precision | x_0 %.9g value units | local spacing %.9g value units | ' ...
            'stored h %.9g value units (%.4g local ULP)\n' ...
            'changed %d | absorbed %d | expected change %.9g | observed change %.9g | ' ...
            'final error %.4g starting ULP'], ...
            out.storedStart,out.spacingAtStart,out.storedIncrement,out.incrementInUlps, ...
            out.changedSteps,out.unchangedSteps,out.expectedChange,out.observedChange, ...
            out.finalErrorInUlps);
    end
end
