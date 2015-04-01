function pNormalised = normalisePDF(x_limits,pNonNormalised)

resolution = 0.001;

xInterpolationValues = min(x_limits):resolution:max(x_limits);

pInterpolationValues = interpolateValues(x_limits, pNonNormalised, xInterpolationValues);

normalisationFactor =  1/ (resolution * sum(pInterpolationValues));

pNormalised = pNonNormalised * normalisationFactor;

end