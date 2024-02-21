function TCS_stimulate(TCS,target_temperature,trigger_code)

%surface area : string '11111'
st=['S11111'];
print_to_serial(TCS,st,0);

%temperature slope
temperature_slope=300;
st=['V0' sprintf('%04d',round(temperature_slope*10))];
print_to_serial(TCS,st,0);

%temperature return slope
%st=['R0' sprintf('%04d',round(temperature_slope*10))];
%print_to_serial(TCS,st,0);

%stimulus duration (in ms)
stimulus_duration=200;
st=['D0' sprintf('%05d',round(stimulus_duration))];
print_to_serial(TCS,st,0);

%stimulation temperature : target_temperature in °C
st=['C0' sprintf('%03d',round(target_temperature*10))];
print_to_serial(TCS,st,0);

%UW
%st=['Uw11111003001' sprintf('%03d',round(target_temperature*10)) '024' sprintf('%03d',round(target_temperature*10)) '001320'];
%print_to_serial(TCS,st,0);

%trigger
st=['T' trigger_code '010'];
print_to_serial(TCS,st,0);

%launch stimulation
print_to_serial(TCS,'L',0);
