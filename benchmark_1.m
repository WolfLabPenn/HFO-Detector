% clc;
clear;
%%
if ~exist('.\Functions','dir')
    error('Please put the script in the same directory as the Function folder')
else
    addpath('.\Functions');
end
%%
% You can also find the data and the dector by Donos et al. here:
% https://bitbucket.org/cristidonos/hfodetector/src/master/
if ~exist('.\Data','dir')
    error('Please put the script in the same directory as the Data folder to run benchmark_1')
else
    load('.\Data\Donos_signal_2.mat');
    load('.\Data\Donos_ground_truth_2.mat');
    load('.\Data\Donos_paper_F1Score.mat');
    gt(:,4)= 0.5:1:300; % Ground truth
    fs= 2000; % Sampling frequency of benchmark data
end
%% General parameters
parameters.channels= 1:6; % Channels to loop through
parameters.fs= fs; % Sampling frequency
parameters.chunks= 1; % Breaking data into smaller chunks
parameters.verbose= true; % Display some information
%% Continuous wavelet transform (CWT) parameters
parameters.wavelet= 'morse'; % Type of wavelet
parameters.WaveletParameters= [9,120]; % Parameters of wavelet.
parameters.VoicesPerOctave= 16; % Voices per octave
parameters.FrequencyLimits= [15,1000]; % Frequncy range for CWT analysis
parameters.gpu= true; % Using gpu for CWT
%% Parameters for detecting and characterizing blobs
parameters.compare= 'magnitude'; % Use "amplidute" or "power" for comparison
parameters.center= 'mean'; % Use "mean" or "max" as the center
parameters.unimodal= true; % Making sure detected blobs are unimodal
%% Ripple detection parameters
parameters.ripple.ecdf= 0.993; % Cutoff threshold
parameters.ripple.range= [80,250]; % Frequency range to detect ripples
parameters.ripple.n_cyles= 3; % Number of cycles a ripple must have at the "center" frequency
parameters.ripple.frequency_range_th= 98/100; % Allowable difference between lowest and higher frequncy of a blob
parameters.ripple.mean_th= 3.5; % Threshold that a blob mean/max needs to be compared to all the data at its central frequency
parameters.ripple.ext= 500; % Upper limit allowed for comparison
parameters.ripple.save_ecdf= false; % Saving ecdf results is unnecessary and takes large space
%% Fast-ripple detection parameters
parameters.fast_ripple= []; % Not interested in detecting fast ripples in this dataset.
%% Spike detection parameters
parameters.spike= []; % Not interested in detecting fast ripples in this dataset.
%% Detecting HFOs
results= HFO_detector(signal,parameters); % Calling HFO detector function
%% Comparing the results with the published data for Donos et al. dataset
% https://doi.org/10.3389/fnins.2020.00183
delta_t= 0.1; % The window size [s] to check for true positives (TP), false positives (FP), and false negatives (FN)
F_all= zeros(4,6);
N=1e6;
for i= 1:4
    test=zeros(1,N);
    n=0;
    for j=1:parameters.chunks
        temp=[results.channel(i,j).ripples.center];
        temp=[temp.time];
        test(n+1:n+length(temp))=temp;
        n=n+length(temp);
    end
    test(n+1:N)=[];
    [TP,FP,FN,~]= compare_resutls(test,gt(:,4),delta_t); % Comparing detected HFOs with ground truth
    F= sum(TP,1)./(sum(TP,1)+0.5*(sum(FP,1)+sum(FN,1)));
    F_all(i,:)= [F,F1Score(i,:)];
end
% Plotting the results
bar(F_all);
xticklabels({'-9dB','-6dB','-3dB','0dB'})
xlabel('SNR')
ylabel('F-Measure')
legend('Ours','Donos','Hilbert','STE','SLL','MNI','Location','northoutside','Orientation','horizontal','Box','off')
