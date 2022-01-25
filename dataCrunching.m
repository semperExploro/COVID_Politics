%jyoun127:12/06/2021:MatlabR2021a
clear;clc;close all;
%% grab data

% open files and import data
data = fopen('us-states.csv',"r");
listOfStates = fopen('listOfStates.txt','r');
politicalAffilation = fopen('poliAfil.txt');

% scan files for data
coronavirusData = textscan(data,"%*s %*s %s %f %f %f %f %f %f","delimiter",",","headerlines",1); % coronavirus data
stateNames = textscan(listOfStates,"%s",'delimiter',',');                                        % scan for state names
politicalData = textscan(politicalAffilation, "%s%d%d%*s%*s%*s%*s",'delimiter',",");             % obtain political data

%% obtain columns of fields
states=string(stateNames{1,1});        % list of states
dataNames=string(coronavirusData{:,1});% state names in the data file
dataAvg100k=coronavirusData{:,4};      % obtain data for cases
dataAvg100kDeaths = coronavirusData{:,7}; % obtain data for deaths

%% computation
acquireData=[];                        % compile cases and deaths into one array
democratSorted=[];                     % an array of percentage of democrats corresponding to each state
democrat = politicalData{1,2};         % obtain values pertaining to percentage of democrats

for index=1:size(states,1)
    %% cases computation
    averageCases = mean(dataAvg100k(states(index,1) == dataNames));        %acquire average cases per state and find average
    averageDeaths = mean(dataAvg100kDeaths(states(index,1) == dataNames)); %acquire average deaths per state and find average
    acquireData=[acquireData;averageCases,averageDeaths];                  %compile into one array
    
    %% party computation 
    democratSorted=[democratSorted;democrat(string(politicalData{1,1})==states(index,1))]; %sort democratic data in accordance with states, just to make sure graphing x and y points match
end

%% plotting

% average cases
figure
plot(democratSorted,acquireData(:,1),"b.",'MarkerSize',20);
title("The Effect of State Political Affiliation on Coronavirus Cases", 'FontSize', 14);
hold on
[line,goodOne]=fit(double(democratSorted),acquireData(:,1),"poly1");
p=plot(line,'r-');
p.LineWidth=2;
hold on;
caption = sprintf('y = %.4f * x + %.4f', line.p1, line.p2);
xlabel("Percentage of Democrats in State" ,'FontSize', 10);
ylabel("Average Cases Per 100k for 2020-2021",'FontSize', 10);
legend('States Cases vs Party Affiliation Percentages',caption);
set(gcf,'color','w');
grid on
hold off
fprintf("FOR CASES: Goodness for fit %f\n %s\n",(goodOne.rsquare),' Which signifies a decent fit, though does not necessarily mean strong correlation between states political status and total cases');
saveas(gcf,'Cases Graph.png')


% average deaths
figure
plot(democratSorted,acquireData(:,2),"b.",'MarkerSize',20);
title("The Effect of State Political Affiliation on Coronavirus Deaths", 'FontSize', 14);
hold on
[deathLine,goodTwo]=fit(double(democratSorted),acquireData(:,2),"poly1");
m=plot(deathLine,'r-');
m.LineWidth=2;
caption = sprintf('y = %.4f * x + %.4f', deathLine.p1, deathLine.p2);
xlabel("Percentage of Democrats in State",'FontSize', 10);
ylabel("Average Deaths Per 100k for 2020-2021",'FontSize', 10);
legend('States Cases vs Party Affiliation Percentages',caption);
set(gcf,'color','w');
grid on
fprintf("FOR DEATHS: Goodness for fit %f\n %s\n",(goodTwo.rsquare),' Which signifies poor correlation, signifying that there is no correlation between deaths and states political status');
hold off
saveas(gcf,'Death Graph.png')

%% write data files
lineString = evalc('line');
deathString = evalc('deathLine');
writeID = fopen("analysisResults.txt","w");
fprintf(writeID,"Line of best fit pertaining the cases per 100k\n%s\n",lineString);
fprintf(writeID,"Goodness for fit %f\n %s\n\n",(goodOne.rsquare),' Which signifies a decent fit, though does not necessarily mean strong correlation between states political status and total cases');
fprintf(writeID,"Line of best fit pertaining the deaths per 100k\n%s\n",deathString);
fprintf(writeID,"Goodness for fit %f\n %s\n",(goodTwo.rsquare),' Which signifies poor correlation, signifying that there is no correlation between deaths and states political status');
fclose(writeID);

%% close file ptrs
fclose(listOfStates);
fclose(data);