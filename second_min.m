function [ y ] = second_min( x )
   y = min(x(x>min(x)));
end