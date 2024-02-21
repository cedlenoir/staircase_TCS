% debug?
debug = 0;

result = [];

session_string = 'SESSION1';
subject_string = 'subject';

filename = [subject_string ' ' session_string ' ' datestr(now,'mmmm-dd-yyyy-HH-MM-SS')];

% initialize TCS, baseline temperature is 32°C, max temperature is 70°C
disp('Initialize TCS');
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

disp('TCS Initialized');

% parameters

% fixed_temp = 62;
% neutral_temp_hand = 35;
% neutral_temp_foot = 35;

initial_temp_hand = 60;
% initial_temp_foot = 64;

trial_count_hand = 0;
% trial_count_foot = 0;

num_reversals_hand = 0;
num_reversals_foot=0;

% choose number of reversal to reach to stop the procedure
requested_reversals = 4;
% requested_trials=40;

variable_temp_hand = initial_temp_hand;
% variable_temp_foot=initial_temp_foot;

temperature_step_hand = 1;
temperature_step_foot = 1;

trial_switch = 1;

ok = 1;
ok_hand = 1;
ok_foot = 1;

answers_foot = [];
answers_hand = [];
foot_ratings = [];
hand_ratings = [];

response_ok = 0;

while ok == 1
    % hand is variable
    if ok_hand == 1
        trial_count_hand = trial_count_hand+1;
        
        response_ok = 0;
        while response_ok == 0
            disp('FOOT is fixed, HAND is variable');
            disp(['TRIAL : ' num2str(trial_count_hand)]);
            % deliver stimulus constant stimulus on foot = site 1)
            disp(['First stimulus on FOOT (fixed) : ' num2str(fixed_temp)]);
            
            % reset neutral temp foot
            % TCS_set_neutral(TCS,neutral_temp_foot);
            
            pause;
            pause(rand()*0.5+0.5);
            if debug == 0
                % result.data_hand_1(trial_count_hand).data=LSD_stimulate_2(NI,1,fixed_temp,stim_duration,1);
                % TCS_stimulate(TCS,'11111',fixed_temp,300,stim_duration,255);
                TCS_stimulate(TCS,fixed_temp,'001');
                
            end

            % deliver variable stimulus on hand = site 2)
            disp(['Second stimulus on HAND (variable) : ' num2str(variable_temp_hand(end))]);
            
            % set neutral temp for hand
            % TCS_set_neutral(TCS,neutral_temp_hand);
            
            pause(rand()*0.5+0.5)
            pause
            if debug == 0
                % result.data_hand_2(trial_count_hand).data=LSD_stimulate_2(NI,2,variable_temp_hand(end),stim_duration,0);
                % TCS_stimulate(TCS,'11111',variable_temp_hand(end),300,stim_duration,254);
                TCS_stimulate(TCS,variable_temp_hand(end),'003');
            end

            % collect response from participant
            a=input('Which stimulus was strongest (1=FOOT, 2=HAND, other=RESTART)','s');
            switch a
                case '1'
                    response_ok=1;
                    answers_hand(end+1)=1;
                case '2'
                    response_ok=1;
                    answers_hand(end+1)=2;
            end;
            
            if response_ok==0;
                disp('RESTARTING!');
            end;
        end;
        %collect rating
        b=input('Rating first stimulus (FOOT) (0-100)','s');
        foot_ratings{end+1}=b;

        %was there a reversal?
        if length(answers_hand)>1
            if answers_hand(end)==answers_hand(end-1)
%             if variable_temp_hand(end)-variable_temp_hand(end-1)==variable_temp_hand(end-1)-variable_temp_hand(end-2)
            else
                %there was a reversal
                num_reversals_hand=num_reversals_hand+1;
                %reduce step if first reversal
                if num_reversals_hand==1
                    temperature_step_hand=temperature_step_hand/2;
                end;
            end;
        end;
        %set temperature of next trial
        switch a
            case '1'
                %Foot was stronger so we increase hand
                variable_temp_hand(end+1)=variable_temp_hand(end)+temperature_step_hand;
            case '2'
                %Foot was weaker so we decrease hand
                variable_temp_hand(end+1)=variable_temp_hand(end)-temperature_step_hand;
        end;

        disp(['Number of reversals : ' num2str(num_reversals_hand)]);
        disp(['Number of trials : ' num2str(trial_count_hand)]);
        disp('');
        %have we reached the number of reversals & the requested number of trials?
        if num_reversals_hand>=requested_reversals && trial_count_hand>=requested_trials
            ok_hand=0;
            disp('HAND variable FINISHED!');
        end;
    end;
    
    %foot is variable
    if ok_foot==1;
        trial_count_foot=trial_count_foot+1;
        response_ok=0;
        while response_ok==0;
            disp('HAND is fixed, FOOT is variable');
            disp(['TRIAL : ' num2str(trial_count_foot)]);
            %deliver stimulus constant stimulus on hand = site 2)
            disp(['First stimulus on HAND (fixed) : ' num2str(fixed_temp)]);
            
            %reset neutral temp for hand
            %TCS_set_neutral(TCS,neutral_temp_hand);
            pause;
            pause(rand()*0.5+0.5);
            
            if debug==0;
                %result.data_foot_1(trial_count_foot).data=LSD_stimulate_2(NI,2,fixed_temp,stim_duration,1);
                %TCS_stimulate(TCS,'11111',fixed_temp,300,stim_duration,255);
                TCS_stimulate(TCS,fixed_temp,'002'); %trigger code same as fixed temp on foot ?
                
            end;
            %deliver variable stimulus on foot = site 1)
            disp(['Second stimulus on FOOT (variable) : ' num2str(variable_temp_foot(end))]);
            
            %reset neutral temp for foot
            %TCS_set_neutral(TCS,neutral_temp_foot);
            
            pause;
            pause(rand()*0.5+0.5);
            
            if debug==0;
                %result.data_foot_2(trial_count_foot).data=LSD_stimulate_2(NI,1,variable_temp_foot(end),stim_duration,0);
                %TCS_stimulate(TCS,'11111',variable_temp_foot(end),300,stim_duration,254);
                TCS_stimulate(TCS,variable_temp_foot(end),'003'); %trigger code same as variable temp hand ?
            end;
            %collect response from participant
            a=input('Which stimulus was strongest (1=FOOT, 2=HAND)','s');
            switch a
                case '1'
                    %Foot was stronger so we decrease foot
                    response_ok=1;
                    answers_foot(end+1)=1;
                case '2'
                    %Hand was stronger so we increase foot
                    response_ok=1;
                    answers_foot(end+1)=2;
            end;
            if response_ok==0;
                disp('RESTARTING!');
            end;
        end;
        %rating
        b=input('Rating first stimulus (HAND) (0-100)','s');
        hand_ratings{end+1}=b;

        %was there a reversal?
        if length(answers_foot)>1
            if answers_foot(end)==answers_foot(end-1)
%             if variable_temp_hand(end)-variable_temp_hand(end-1)==variable_temp_hand(end-1)-variable_temp_hand(end-2)
            else
                %there was a reversal
                num_reversals_foot=num_reversals_foot+1;
                %reduce step if first reversal
                if num_reversals_foot==1
                    temperature_step_foot=temperature_step_foot/2;
                end;
            end;
        end;
        %adjust temperature of next trial
        switch a
            case '1'
                %Foot was stronger so we decrease foot
                variable_temp_foot(end+1)=variable_temp_foot(end)-temperature_step_foot;
            case '2'
                %Hand was stronger so we increase foot
                variable_temp_foot(end+1)=variable_temp_foot(end)+temperature_step_foot;
        end;

        disp(['Number of reversals : ' num2str(num_reversals_foot)]);
        disp(['Number of trials : ' num2str(trial_count_foot)]);
        disp('');
        %have we reached the number of reversals & the requested number of trials?
        if num_reversals_foot>=requested_reversals && trial_count_foot>=requested_trials
            ok_foot=0;
            disp('FOOT variable FINISHED!');
        end;
    end;    
    %are we finished?
    if ok_hand==0 && ok_foot==0
        ok=0;
        disp('WE ARE FINISHED!');
    end;
    
    result.variable_temp_hand=variable_temp_hand;
    result.variable_temp_foot=variable_temp_foot;
    result.answers_foot=answers_foot;
    result.answers_hand=answers_hand;
    
    result.hand_ratings=hand_ratings;
    result.foot_ratings=foot_ratings;

    try
        foot_ratings_numeric=cell2mat(foot_ratings);
        result.foot_ratings_numeric=foot_ratings_numeric;
    end;
    try
        hand_ratings_numeric=cell2mat(hand_ratings);
        result.hand_ratings_numeric=hand_ratings_numeric;
    end;
  
    save(filename,'result');
    
end        

% find reversals
result.reversals_foot=zeros(1,length(result.answers_foot));
for i=2:length(result.answers_foot);
    if result.answers_foot(i)==result.answers_foot(i-1);
    else
        result.reversals_foot(i)=1;
    end;
end;

[a,b]=find(result.reversals_foot==1);
c=result.variable_temp_foot(b);
result.foot_threshold=mean(c(end-3:end));

result.reversals_hand=zeros(1,length(result.answers_hand));
for i=2:length(result.answers_hand);
    if result.answers_hand(i)==result.answers_hand(i-1);
    else
        result.reversals_hand(i)=1;
    end;
end;

[a,b]=find(result.reversals_hand==1);
c=result.variable_temp_hand(b);
result.hand_threshold=mean(c(end-3:end));


save(filename,'result');


