function TCS=TCS_initialize(COMport,neutral_temperature,max_temperature);
%COMport : string (e.g. 'COM3')
%neutral_temp : 15-40 (unit = 1°C)
disp('Initializing TCS');
if isempty(instrfind);
else
    fclose(instrfind);
end;
disp('Initializing the TCS device. This may take a few seconds.');
TCS=serial(COMport,'BaudRate',115200);
fopen(TCS);

%set neutral temperature
st=['N' sprintf('%03d',neutral_temperature*10)];
print_to_serial(TCS,st,0);

%set maximum temperature
st=['Ox' sprintf('%02d',max_temperature)];
print_to_serial(TCS,st,0);

%disable U mode
st='Ue00000';
print_to_serial(TCS,st,0);

%mute mode
st='F';
print_to_serial(TCS,st,0);
disp('TCS initialized');