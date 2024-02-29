%PARAMETERS
%debug?
debug=1;
%TCS com port
TCS_comport='COM5';
%TCS neutral temp
TCS_neutraltemp=35;
%TCS maximum temp
TCS_maxtemp=70;
%reference temperature
TCS_reftemp=62;
%initial temperature delta
TCS_initial_delta=4;
%step size
TCS_step_size=1;
%number of reversals
requested_reversals=6;

%session string
session_string='SESSION1'
%subject string
subject_string='MARC_HENRI';


%initialize TCS
if debug==0
    disp('Initialize TCS');
    TCS=TCS_initialize(TCS_comport,TCS_neutraltemp,TCS_maxtemp);
    disp('TCS Initialized');
end;;

%init variables
result=[];
filename=[subject_string ' ' session_string ' ' datestr(now,'mmmm-dd-yyyy-HH-MM-SS')];
disp(filename);

trial_count_hand_foot=0;
trial_count_foot_hand=0;

num_reversals_hand_foot=0;
num_reversals_foot_hand=0;

delta_temp_hand_foot=TCS_initial_delta;
delta_temp_foot_hand=TCS_initial_delta;

trial_switch=1;
ok=1;
ok_hand_foot=1;
ok_foot_hand=1;

answers_hand_foot=[];
answers_foot_hand=[];

response_ok=0;

while ok==1;
    if or(ok_hand_foot==1,ok_foot_hand==1);
        %Staircase 1 : stimulus 1 = hand, stimulus 2 = foot
        trial_count_hand_foot=trial_count_hand_foot+1;     
        response_ok=0;
        while response_ok==0
            disp('STIM1 = HAND, STIM2 = FOOT');
            disp(['TRIAL : ' num2str(trial_count_hand_foot)]);
            temp_hand=TCS_reftemp-(delta_temp_hand_foot(end)/2);
            temp_foot=TCS_reftemp+(delta_temp_hand_foot(end)/2);
            disp(['First stimulus on HAND : ' num2str(temp_hand)]);            
            pause;
            pause(rand()*0.5+0.5);
            if debug==0;
                TCS_stimulate(TCS,temp_hand,'001');                
            end;
            disp(['Second stimulus on FOOT : ' num2str(temp_foot)]);
            pause(rand()*0.5+0.5);
            pause;
            if debug==0;
                TCS_stimulate(TCS,temp_foot,'003');
            end;
            %collect response from participant
            a=input('Which stimulus was strongest (1=FOOT, 2=HAND, other=RESTART)','s');
            switch a
                case '1'
                    response_ok=1;
                    answers_hand_foot(end+1)=1;
                case '2'
                    response_ok=1;
                    answers_hand_foot(end+1)=2;
            end;            
            if response_ok==0;
                disp('RESTARTING!');
            end;
        end;
        %was there a reversal?
        if length(answers_hand_foot)>1
            if answers_hand_foot(end)==answers_hand_foot(end-1)
            else
                %there was a reversal
                num_reversals_hand_foot=num_reversals_hand_foot+1;
            end;
        end;
        %set temperature of next trial
        switch a
            case '1'
                %Foot was stronger so we decrease the hand minus foot delta
                delta_temp_hand_foot(end+1)=delta_temp_hand_foot(end)-(TCS_step_size*0.871);
            case '2'
                %Hand was stronger so we increase the hand minus foot delta
                delta_temp_hand_foot(end+1)=delta_temp_hand_foot(end)+TCS_step_size;
        end;
        disp(['Number of reversals : ' num2str(num_reversals_hand_foot)]);
        disp(['Number of trials : ' num2str(trial_count_hand_foot)]);
        disp('');
        %have we reached the number of reversals?
        if num_reversals_hand_foot>=requested_reversals
            ok_hand_foot=0;
            disp('HAND>FOOT : we have collected the number of requested reversals!');
        end;

    
        %Staircase 2 : stimulus 1 = foot, stimulus 2 = hand
        trial_count_foot_hand=trial_count_foot_hand+1;
        response_ok=0;
        while response_ok==0;
            disp('STIM1 = FOOT, STIM2 = HAND');
            disp(['TRIAL : ' num2str(trial_count_foot_hand)]);
            temp_hand=TCS_reftemp-(delta_temp_foot_hand(end)/2);
            temp_foot=TCS_reftemp+(delta_temp_foot_hand(end)/2);
            disp(['First stimulus on FOOT  : ' num2str(temp_foot)]);    
            pause;
            pause(rand()*0.5+0.5);            
            if debug==0;
                TCS_stimulate(TCS,temp_foot,'003'); 
            end;
            disp(['Second stimulus on HAND : ' num2str(temp_hand)]);
            pause;
            pause(rand()*0.5+0.5);
            if debug==0;
                TCS_stimulate(TCS,temp_hand,'001'); 
            end;
            %collect response from participant
            a=input('Which stimulus was strongest (1=FOOT, 2=HAND, other=RESTART)','s');
            switch a
                case '1'
                    response_ok=1;
                    answers_foot_hand(end+1)=1;
                case '2'
                    response_ok=1;
                    answers_foot_hand(end+1)=2;
            end;
            if response_ok==0;
                disp('RESTARTING!');
            end;
        end;
        %was there a reversal?
        if length(answers_foot_hand)>1
            if answers_foot_hand(end)==answers_foot_hand(end-1)
            else
                %there was a reversal
                num_reversals_foot_hand=num_reversals_foot_hand+1;
            end;
        end;
        %set temperature of next trial
        switch a
            case '1'
                %Foot was stronger so we decrease the hand minus foot delta
                delta_temp_foot_hand(end+1)=delta_temp_foot_hand(end)-(TCS_step_size*0.871);
            case '2'
                %Hand was stronger so we increase the hand minus foot delta
                delta_temp_foot_hand(end+1)=delta_temp_foot_hand(end)+TCS_step_size;
        end;
        disp(['Number of reversals : ' num2str(num_reversals_foot_hand)]);
        disp(['Number of trials : ' num2str(trial_count_foot_hand)]);
        disp('');
        %have we reached the number of reversals?
        if num_reversals_foot_hand>=requested_reversals
            ok_foot_hand=0;
            disp('FOOT>HAND : we have collected the number of requested reversals!');
        end;
    end;    
    
    %are we finished?
    if ok_hand_foot==0 && ok_foot_hand==0
        ok=0;
        disp('WE ARE FINISHED!');
    end;
    
    result.delta_temp_hand_foot=delta_temp_hand_foot;
    result.delta_temp_foot_hand=delta_temp_foot_hand;
    result.answers_hand_foot=answers_hand_foot;
    result.answers_foot_hand=answers_foot_hand;

    save(filename,'result');
    
end        

% find reversals
result.reversals_hand_foot=zeros(1,length(result.answers_hand_foot));
result.reversals_foot_hand=result.reversals_hand_foot;

for i=2:length(result.answers_hand_foot);
    if result.answers_hand_foot(i)==result.answers_hand_foot(i-1);
    else
        result.reversals_hand_foot(i)=1;
    end;
end;

for i=2:length(result.answers_foot_hand);
    if result.answers_foot_hand(i)==result.answers_foot_hand(i-1);
    else
        result.reversals_foot_hand(i)=1;
    end;
end;

[a,b]=find(result.reversals_hand_foot==1);
c=result.delta_temp_hand_foot(b);
result.hand_foot_threshold=mean(c(3:2+num_reversals));

[a,b]=find(result.reversals_foot_hand==1);
c=result.delta_temp_foot_hand(b);
result.foot_hand_threshold=mean(c(3:2+num_reversals));

save(filename,'result');


