function [hC vC] = SmoothnessTerm(im)
[dh dv] = gradient(im);
dh = sum(dh.^2, 3);
dv = sum(dv.^2, 3);
hC = exp(-.5.*dh./mean(dh(:)));
vC = exp(-.5.*dv./mean(dv(:)));