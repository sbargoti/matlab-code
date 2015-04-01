function P = interpolateValues(x, p, O)

% O - 1xT
P = zeros(size(O));
N = length(x);

indices = (O <= x(1));
P(indices) = p(1);

indices = (O  >= x(N));
P(indices) = p(N);

for i = 1:length(x)-1
   indices =  (O >= x(i) & O < x(i+1));
   distances = O(indices) - x(i);
   values = p(i) + (p(i+1) - p(i))/(x(i+1) - x(i)) * distances;
   P(indices) = values;
end




end