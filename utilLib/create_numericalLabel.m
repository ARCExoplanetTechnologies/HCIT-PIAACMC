function [labelOut] = create_numericalLabel(currentNum, labelLength)

    labelOut = num2str(currentNum);
    for ilabel = 1:labelLength
        if currentNum < 10^(ilabel - 1)
            labelOut = ['0' labelOut];
        end
    end


end

