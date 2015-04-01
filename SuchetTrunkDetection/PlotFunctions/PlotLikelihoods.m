function PlotLikelihoods(points2D,xVals,Likelihoods)
% Plot the likelihoods of the different states in the HSMM model over all
% observations

figure('color','white')
plot(points2D(1:3:end,1),points2D(1:3:end,2),'.'); hold all;
axis equal;

% Plot all likelihoods
lColors = colormap(hsv(size(Likelihoods,2)));
for i = 1:size(Likelihoods,2)
    % Rescale
    L =  Likelihoods(:,i)/max(Likelihoods(:,i))*max(points2D(:,2))*0.75;
    plot(xVals,L,'-','linewidth',2,'color',lColors(i,:))
end

end