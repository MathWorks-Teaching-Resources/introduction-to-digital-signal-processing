%  Initialization script for AnalogToDigitalConversion.mlx
% ---- Known Issues     -----
KnownIssuesID = "MATLAB:minrhs";
% ---- Pre-run commands -----
audioread = @(x) NewAudioRead();
audioplayer = @(x) disp("Create audio player");
play = @(x) disp("Playing audio");
stop = @(x) disp("Stop audio player");
function varargout=NewAudioRead(varargin)
load(fullfile(currentProject().RootFolder,"SoftwareTests\InitFiles\InitAnalogToDigitalConversion.mat"));
varargout={JazzSignal,JazzSamplingFreq};
end