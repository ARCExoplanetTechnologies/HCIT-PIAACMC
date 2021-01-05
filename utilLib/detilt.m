%+
%  detilt - remove tilt over an aperture
%
%  USAGE:
%    phdt = detilt(ph,ap)
%
%  INPUTS:
%    ph - phase
%    ap - aperture
%
%  OUTPUTS:
%    phdt - phase with tilt removed
%    tx, ty - (optional) tip and tilt coefficients (units: phase/pixel)
%
%-
function phdt= detilt(ph,ap,tx,ty)
  info = whos('ph');,dims=info.size; 
  n = dims(1);,  m = dims(2);
  if length(ap) == 0, ap = ones(n,m);, end
  x = ones(n,1)* (-m/2+1:1:m/2) ;   %( (    findgen(n) # (fltarr(m)+1)) - n/2)
  x = x - sum(sum(x.*ap))/sum(sum(ap));
  y = (-n/2+1:1:n/2)'*ones(1,m) ;            %( ( (fltarr(n)+1) #   findgen(m) ) - m/2)
  y - sum(sum(y.*ap))/sum(sum(ap));
  tx = sum(sum(ph.*x.*ap))/sum(sum(x.*x.*ap));
  ty = sum(sum(ph.*y.*ap))/sum(sum(y.*y.*ap));
  phdt = (ph - tx.*x - ty.*y);
 