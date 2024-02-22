function result = staircase_detection_TCS

% debug?
debug = 0;

% prepare strucutre and file name for saving
result = [];
% indicate subject ID, type of probe and number of reversals
prompt = {'\fontsize{12} Subject ID: ','\fontsize{12} Probe (small -> 1 OR classic -> 2): ',...
    '\fontsize{12} Number reversals : '};
dlgtitle = 'Threshold';
opts.Interpreter = 'tex';
dims = repmat([1 50],3,1);
definput = {'','','5'};
info = inputdlg(prompt,dlgtitle,dims,definput,opts);
subject_id = str2double(info(1));
session = str2double(info(2));
requested_reversals = str2double(info(3));
if session == 1
    probe = 'small';
elseif session == 2
    probe = 'classic';
end
filename = ['sub-' num2str(subject_id) ' probe-' probe '_' datestr(now,'mmmm-dd-yyyy-HH-MM-SS')];

% initialize TCS, baseline temperature is 32°C, max temperature is 70°C
clc
disp('Initialize TCS');
if debug == 0
    COM = tcs2.find_com_port;
    tcs2.init_serial(COM)
    tcs2.init_tcs;
    tcs2.set_trigger_in('on')
    tcs2.write_serial('B')
    pause()
    disp('BATTERY OK ? press ENTER')
    tcs2.set_neutral_temperature(32);
    tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 °C !! Not available for all firwmare version.
    tcs2.write_serial('Om700'); % set max temperature to 70°

    % set stimulation parameters
    StimDuration = 200; %(ms)
    RampUp = 300;         %(deg/s)
    RampDown = 300;       %(deg/s)
    tcs2.set_stim_duration(StimDuration,RampUp,RampDown);
    pause(0.1)
    tcs2.enable_temperature_feedback(100);
    pause(0.1)
    disp('TCS Initialized');
    disp(' ')
end

% parameters (possiblity to change starting temperature depending on the probe!)
if session == 1 % probe = 'small';
    start_temp = 50; % starting temperature
elseif session == 2 % probe = 'classic';
    start_temp = 50; % starting temperature
end

trial_count = 0;
num_reversals = 0;
current_temp = start_temp;
temperature_step1 = 1;
temperature_step2 = 0.5;
temperature_step = temperature_step1;
ok = 0;
answers = [];
ratings = [];

while ok == 0

    trial_count = trial_count+1;
    disp(['TRIAL # ',num2str(trial_count)]);
    disp(['Number of reversals : ', num2str(num_reversals)]);
    disp(' ');

    % deliver stimulus stimulus at starting temperature
    disp('PRESS TO STIMULATE');
    disp(' ');
    pause
    pause(rand*0.5+0.5)
    if debug == 0
        tcs2.set_stim_temperature(current_temp(end))
        tcs2.stimulate
    end
    disp(['-> stimulation at ', num2str(current_temp(end)),' °C']);

    % get response from participant : detected or not?
    a = input('Did you feel the stimulation? (y or n) ','s');
    %collect rating if perceived
    if a == 'y'
        b = input('Rating (0-100): ','s');
        ratings{end+1} = b;
    elseif a == 'n'
        ratings{end+1} = 'NaN';
    end

    % adjust temperature for the next trial
    switch a
        case 'y'
            answers(end+1) = 1;
            current_temp(end+1) = current_temp(end) - temperature_step;

        case 'n'
            answers(end+1) = 0;
            current_temp(end+1) = current_temp(end) + temperature_step;
    end

    % was there a reversal?
    if length(answers) > 1
        if answers(end) == answers(end-1)
        else
            % there was a reversal
            num_reversals = num_reversals+1;
            % reduce step if first reversal
            if num_reversals >= 1
                temperature_step = temperature_step2;
            else
                temperature_step = temperature_step1;
            end
        end
    end

    % Have we reached the number of reversals
    if num_reversals >= requested_reversals
        ok = 1;
        disp('STAIRCASE FINISHED!');
    end
    WaitSecs(1)
    clc

end

% sort and tidy results
result.probe = probe;
result.current_temp = current_temp;
result.answers = answers;
result.ratings = ratings;

try
    ratings_numeric = str2double(ratings);
    result.ratings_numeric = ratings_numeric;
end

% find reversals and compute threshold
result.reversals = zeros(1,length(result.answers));
for i = 2:length(result.answers)
    if result.answers(i) == result.answers(i-1)
    else
        result.reversals(i) = 1;
    end
end

[dum, idx] = find(result.reversals == 1);
c = result.current_temp(idx);
result.threshold = mean(c(end-3:end));

% Plot results
F = figure;
x = 1:1:length(result.current_temp);
plot(x, result.current_temp)
ax = gca;
set(gcf,'Color','w')
ax.Box = 'off';
ax.XLabel.String = 'number of stimuli';
ax.YLabel.String = 'temperature (°C)';
hold on
% yline(result.threshold,'--','threshold')
line([0 length(result.current_temp)],[result.threshold result.threshold],'LineStyle','--')
text(2,result.threshold,'threshold')

sz = 50;
c = [0.4940 0.1840 0.5560];
for rev = 2:length(idx)
    scatter(idx(rev),result.current_temp(idx(rev)),sz,c,'filled')
end

title(['Detection threshold - subject ' num2str(subject_id) ' - ' probe ' probe'])

save(filename,'result')
savefig(F,filename)
clear
end