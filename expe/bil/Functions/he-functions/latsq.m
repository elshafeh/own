function [M, obsolete] = latsq(N)
% LATSQ - Latin Square Matrix
%    M = LATSQ(N) creates a latin square matrix of size N-by-N containing
%    the numbers 1 to N.  N should be a positive integer. 
%
%    A latin square of size N is a N-by-N matrix filled with N different
%    numbers in such a way that each number occurs exactly once in each row
%    and exactly once in each column. They have applications in the design
%    of experiments.  The output M is also known as the (backward shifted)
%    circulant matrix of the vector 1:N.
%
%    Examples:
%    M = latsq(4) % ->
%      %    1  2  3  4
%      %    2  3  4  1
%      %    3  4  1  2
%      %    4  1  2  3
%
%    % latin square of categories
%    C = {'goat','cabbage','wolf'}
%    idx = latsq(numel(C))
%    M = C(idx)
%
%    % Randomized latin square
%    V = randperm(6)
%    M = V(latsq(numel(V)))
%
%    See also MAGIC, GALLERY, 
%             BALLATSQ, CIRCULANT, SLM (File Exchange)
%
%    More information: http://en.wikipedia.org/wiki/Latin_square

% for Matlab R13 and up, last tested in R2017b
% version 2.0 (dec 2017)
% (c) Jos (10584)
% FEX: http://www.mathworks.nl/matlabcentral/fileexchange/authors/10584


% History
% 1.0 (apr 2006) created
% 1.1 (sep 2006) revised for the File Exchange
% 1.2 (sep 2006) fixed minor spelling errors
% 1.3 (sep 2006) fixed small error in randomization
% 1.4 (feb 2009) mention circulant matrices
% 2.0 (dec 2017) removed randomness, added example of creating
%                arbitray latin squares


if nargin ~= 1 || ~isnumeric(N) || numel(N)~=1 || N<1 || fix(N)~=N
    error('Single argument should be a positive integer') ;
end

% setup latin square
% similar to circulant(1:N,-1)
M = [1:N ; ones(N-1,N)] ;
M = rem(cumsum(M)-1,N)+1 ;
% M is now a latin square.

if nargout==2
    % versions < 2.0 allowed for two outputs, the second one being a random
    % latin square. There is an example in the help how to accomplish this
    % easier.
    warning('LATSQ:TwoOutputs','LATSQ with 2 outputs is no longer supported.') ;
    obsolete = [] ;
end
