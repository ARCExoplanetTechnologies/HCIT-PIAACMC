function [out2D] = normalize2D(in2D)
    normFactor = sum(sum(in2D));
    out2D = in2D/normFactor;
end

