function [indShots] = processRunts(sorted,threshold)

% threshold = 10; % number of standard deviations away from the mean we will allow

strictness = 'strict';
Z_score_type = 'modified';

% look at the size of the input
nPixelsPerArray = size(sorted,1);
nShots = size(sorted,2);
nSignals = size(sorted,3);

signal.data = squeeze(mean(sorted,2))';
signal.std = squeeze(std(sorted,0,2))';
switch Z_score_type
    case 'raw'
        test = signal.data - threshold.*signal.std;
    case 'modified'
        % http://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
        signal.median = squeeze(median(sorted,2))';
        signal.MAD = squeeze(mad(sorted,1,2))';
        test = signal.median - (1/0.6745)*threshold.*signal.MAD;
end

% generic to nSignals -- generate a logical index of good and bad shots,
% based on our rejection criterion (default: modified Z-score)
test2 = reshape(test',[ nPixelsPerArray 1 nSignals ]);
ind3 = bsxfun(@lt,sorted,test2); % probe
ind = logical(sum(ind3,3));

% the 'if' is my test for whether or not to throw a shot away. Basically,
% were at least HALF of the pixels outside of the threshold we defined. The
% 'else' is Zhe's test -- throw away a shot if ANY pixels fail our
% threshold. Right now, it's set to default to Zhe's.
switch strictness
    case 'lax'
        tabTest = mean(ind,1);
        indShots = ~logical(tabTest >= 0.5);
    case 'strict'
        indShots = ~any(ind);
end