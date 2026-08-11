function interactive
fig=uifigure('Name','P01 Gradient Descent','Position',[100 100 1120 720]);
g=uigridlayout(fig,[3 5]); g.RowHeight={'1x','1x',100};
axPath=uiaxes(g); axPath.Layout.Row=[1 2]; axPath.Layout.Column=[1 3];
axF=uiaxes(g); axF.Layout.Row=1; axF.Layout.Column=[4 5];
summary=uilabel(g,'WordWrap','on'); summary.Layout.Row=2; summary.Layout.Column=[4 5];

a=uislider(g,'Limits',[0.001 0.5],'Value',0.08,'MajorTicks',[0.001 0.05 0.1 0.2 0.3 0.5]);
a.Layout.Row=3; a.Layout.Column=1;
c=uislider(g,'Limits',[1 80],'Value',10,'MajorTicks',[1 10 25 50 80]);
c.Layout.Row=3; c.Layout.Column=2;
s=uislider(g,'Limits',[0.5 10],'Value',4); s.Layout.Row=3; s.Layout.Column=3;
it=uislider(g,'Limits',[5 150],'Value',60); it.Layout.Row=3; it.Layout.Column=4;
label=uilabel(g,'Text','step size | condition | start | iterations','WordWrap','on');
label.Layout.Row=3; label.Layout.Column=5;
controls=[a c s it];
for i=1:numel(controls)
    controls(i).ValueChangingFcn=@(~,~) updatePlots();
    controls(i).ValueChangedFcn=@(~,~) updatePlots();
end
updatePlots();

    function updatePlots
        out=model(a.Value,c.Value,s.Value,round(it.Value));
        cla(axPath); contour(axPath,out.x1,out.x2,out.surface,25); hold(axPath,'on');
        plot(axPath,out.x(1,:),out.x(2,:),'o-','LineWidth',1.1); hold(axPath,'off');
        axis(axPath,'equal'); grid(axPath,'on'); xlabel(axPath,'x_1'); ylabel(axPath,'x_2');
        title(axPath,'Path through the objective landscape');

        cla(axF); semilogy(axF,0:numel(out.f)-1,out.f,'LineWidth',1.2);
        grid(axF,'on'); xlabel(axF,'Iteration'); ylabel(axF,'Objective');
        title(axF,'Convergence history');

        summary.Text=sprintf(['alpha %.4f\ncondition %.1f\nspectral radius %.3f\n' ...
            'f_0 %.3g\nf_end %.3g\nconverged %d'],a.Value,c.Value, ...
            out.spectralRadius,out.f(1),out.f(end),out.converged);
    end
end
