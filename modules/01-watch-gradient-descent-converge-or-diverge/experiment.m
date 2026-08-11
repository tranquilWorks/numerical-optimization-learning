%% P01 - Watch Gradient Descent Converge or Diverge
close all; clc;
out=model(0.08,10,4,60);

figure('Name','P01 baseline');
subplot(1,2,1);
contour(out.x1,out.x2,out.surface,25); hold on;
plot(out.x(1,:),out.x(2,:),'o-','LineWidth',1.1);
axis equal; grid on; xlabel('x_1'); ylabel('x_2');
title('Optimization path');
subplot(1,2,2);
semilogy(0:numel(out.f)-1,out.f,'LineWidth',1.3);
grid on; xlabel('Iteration'); ylabel('Objective'); title('Objective convergence');

%% Sweep 1 - step size
alphas=[0.02 0.12 0.24];
figure('Name','P01 step-size sweep'); hold on; grid on;
for i=1:numel(alphas)
    s=model(alphas(i),10,4,60);
    semilogy(0:numel(s.f)-1,s.f,'LineWidth',1.2,'DisplayName', ...
        sprintf('alpha %.2f, rho %.2f',alphas(i),s.spectralRadius));
end
xlabel('Iteration'); ylabel('Objective'); title('Step size moves from slow to unstable');
legend('Location','best');

%% Sweep 2 - conditioning
conditions=[1 10 50];
figure('Name','P01 conditioning sweep');
for i=1:numel(conditions)
    s=model(0.03,conditions(i),4,80);
    subplot(1,3,i); contour(s.x1,s.x2,s.surface,20); hold on;
    plot(s.x(1,:),s.x(2,:),'o-'); axis equal; grid on;
    title(sprintf('condition %.0f',conditions(i)));
end

%% Broken case - unstable step
broken=model(0.25,10,4,30);
figure('Name','P01 broken case');
semilogy(0:numel(broken.f)-1,broken.f,'o-'); grid on;
xlabel('Iteration'); ylabel('Objective');
title(sprintf('Broken: spectral radius %.2f exceeds one',broken.spectralRadius));

assert(out.f(end)<out.f(1),'Baseline should reduce the objective.');
