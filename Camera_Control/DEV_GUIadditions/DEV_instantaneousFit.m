%% Test of instantaneous fits for the camera computer GUI.
% This first section loads a sample image to develop the fitting and
% plotting routine

clear all;

dataPath = 'C:\Users\Alban Urvoy\Dropbox (MIT)\RbLab\ExperimentalData\RamanCooling\2018\07\20180718\data\';
sequenceName = 'UnSweptCool4StageZScanYNScan20180718';
shotNumber = 10;

%load([ datapath 'UnSweptCool4StageZScanYNScan20180718_1.mat' ])

rawAtom = load([ dataPath sequenceName '_' num2str(shotNumber) '_raw.ascii' ]);
noAtom = load([ dataPath sequenceName '_' num2str(shotNumber) '_back.ascii' ]);
noise = load([ dataPath sequenceName '_' num2str(shotNumber) '_noise.ascii' ]);

OD = log(noAtom - noise) - log(rawAtom - noise);

figure(81)
imagesc(OD),colorbar

%% Preparation of the fit
% 

row_min=20; row_max=120; col_min=1; col_max=230; %Region that may have atoms

atomRegion = double(( ((1:size(OD,1))>row_min)&((1:size(OD,1))<row_max) )')*double( ((1:size(OD,2))>col_min)&((1:size(OD,2))<col_max) );
imageOffset = mean(OD(not(atomRegion)));
rmsNoise = std(OD(not(atomRegion)));

hProfile = sum(OD-imageOffset,1); hProfile = reshape(hProfile,1,[]);
vProfile = sum(OD-imageOffset,2); vProfile = reshape(vProfile,1,[]);

% Preparation of the fits
gaussian = @(x,xdata)x(3)*exp(-(xdata-x(1)).^2./(2*(x(2)).^2))+x(4);
options = optimoptions('lsqcurvefit','Display','off');

% Moving average smoothing of the profile for the 1st fit
windowSize = 5; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

hProfileSmooth = filtfilt(b,a,hProfile);
vProfileSmooth = filtfilt(b,a,vProfile); 

% Determination of the initial guesses for the gaussian fit on the top half of the curve
[hmax,himax] = max(hProfileSmooth); [vmax,vimax] = max(vProfileSmooth); % maximum and center of the gaussian
hoff = mean(hProfileSmooth([1 end])); voff = mean(vProfileSmooth([1 end])); % offset for the fit
% indices for the top half of the horizontal cross section defined as the first point that drops below half the peak on each side
hi1 = find(hProfileSmooth(1:himax)<hmax/2,1,'last'); hi2 = (himax-1) + find(hProfileSmooth(himax:end)<hmax/2,1,'first'); 
% indices for the top half of the vertical cross section defined as the first point that drops below half the peak on each side
vi1 = find(vProfileSmooth(1:vimax)<vmax/2,1,'last'); vi2 = (vimax-1) + find(vProfileSmooth(vimax:end)<vmax/2,1,'first'); 

% Defining upper and lower bounds, and initial guesses for the 1st fit 
hub = [ hi2 , numel(hProfileSmooth)/2 , 2*hmax , hoff ]; % upper bounds
hlb = [ hi1 , 0 , 0 , hoff ]; % lower bounds
h0 = [ himax , (hi2-hi1)/2 , hmax-hoff , hoff ]; % initial guesses
vub = [ vi2 , numel(vProfileSmooth)/2 , 2*vmax , voff ]; % upper bounds
vlb = [ vi1 , 0 , 0 , voff ];  % lower bounds
v0 = [ vimax , (vi2-vi1)/2 , vmax-voff , voff ]; % initial guesses

% Perform the 1st fit
hfit = lsqcurvefit(gaussian,h0,hi1:hi2,hProfileSmooth(hi1:hi2),hlb,hub,options);
vfit = lsqcurvefit(gaussian,v0,vi1:vi2,vProfileSmooth(vi1:vi2),vlb,vub,options);

% Defining upper and lower bounds, and initial guesses for the 2nd fit 
hub = [ numel(hProfile) , numel(hProfile) , 2*hmax , max(hProfile) ]; % upper bounds
hlb = [ 1 , 0 , 0 , min(hProfile) ]; % lower bounds
h0 = hfit; % initial guesses
vub = [ numel(vProfile) , numel(vProfile) , 2*vmax , max(vProfile) ]; % upper bounds
vlb = [ 1 , 0 , 0 , min(vProfile) ];  % lower bounds
v0 = vfit; % initial guesses

% Perform the 2nd fit
hfit = lsqcurvefit(gaussian,h0,1:numel(hProfile),hProfile,hlb,hub,options);
vfit = lsqcurvefit(gaussian,v0,1:numel(vProfile),vProfile,vlb,vub,options);


figure(82),clf
subplot(1,2,1)
% plot(sum(OD-imageOffset,2))
plot(1:numel(hProfile),hProfile,1:numel(hProfile),gaussian(hfit,1:numel(hProfile)))
xlim([1 numel(hProfile)])

subplot(1,2,2)
% plot(sum(OD-imageOffset,1))
plot(1:numel(vProfile),vProfile,1:numel(vProfile),gaussian(vfit,1:numel(vProfile)))
xlim([1 numel(vProfile)])




