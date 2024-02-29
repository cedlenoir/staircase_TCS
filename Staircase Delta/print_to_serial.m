function print_to_serial(serial_dev, st, use_fprintf)

if use_fprintf
    %\r = enter
    st = [st, '\r'] ;
    fprintf(serial_dev,st) ;
    %pause(0.001) ;
else
    for i=1:length(st)
        fwrite(serial_dev,st(i),'uchar') ; 
       % pause(0.001) ;
    end
end
% cfr mail Andre Dufour & notice!!! 
% "Ne pas oublier de faire une pause de 1ms entre chaque caractère envoye 
%  au TCS pour etre sur de ne pas en perdre en chemin..."
%edit 17/01/22 This is not necessary with the new firmware

end
