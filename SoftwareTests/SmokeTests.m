classdef SmokeTests < matlab.unittest.TestCase

    properties
        RootFolder
    end
    
    properties (ClassSetupParameter)
        Project = {currentProject()};
    end

    properties (TestParameter)
        File;
    end

    methods (TestParameterDefinition,Static)

        function File = RetrieveFile(Project) %#ok<INUSD>
            % Retrieve student template files:
            RootFolder = currentProject().RootFolder;
            File = dir(fullfile(RootFolder,"Scripts","*.mlx"));
            File = {File.name}; 
        end

    end

    methods (TestClassSetup)

        function SetUpSmokeTest(testCase,Project) %#ok<INUSD>
            % Navigate to project root folder:
            testCase.RootFolder = Project.RootFolder;
            cd(testCase.RootFolder)
            
            % Close the StartUp app if still open:
            delete(findall(groot,'Name','StartUp App'))

            % Log MATLAB version:
            testCase.log("Running in " + version)
        end

    end
    
    methods(Test)

        function SmokeRun(testCase,File)

            % Navigate to project root folder:
            cd(testCase.RootFolder)
            FileToRun = string(File);

            % Pre-test:
            PreFiles = CheckPreFile(testCase,FileToRun);
            run(PreFiles);

            % Run SmokeTest
            disp(">> Running " + FileToRun);
            try
                run(fullfile("Scripts",FileToRun));
            catch ME 
                
            end

            % Post-test:
            PostFiles = CheckPostFile(testCase,FileToRun);
            run(PostFiles)

            % Log every figure created during run:
            Figures = findall(groot,'Type','figure');
            Figures = flipud(Figures);
            if ~isempty(Figures)
                for f = 1:size(Figures,1)
                    if ~isempty(Figures(f).Number)
                        FigDiag = matlab.unittest.diagnostics.FigureDiagnostic(Figures(f),'Formats','png');
                        log(testCase,1,FigDiag);
                    end
                end
            end

            % Close all figures and Simulink models
            close all force
            if any(matlab.addons.installedAddons().Name == "Simulink")
                bdclose all
            end

            % Rethrow error if any
            if exist("ME","var")
                if ~any(strcmp(ME.identifier,KnownIssuesID))
                    rethrow(ME)
                end
            end

        end
            
    end


    methods (Access = private)

       function Path = CheckPreFile(testCase,Filename)
            PreFile = "Pre"+replace(Filename,".mlx",".m");
            PreFilePath = fullfile(currentProject().RootFolder,"SoftwareTests","PreFiles",PreFile);
            if ~isfolder(fullfile(currentProject().RootFolder,"SoftwareTests/PreFiles"))
                mkdir(fullfile(currentProject().RootFolder,"SoftwareTests/PreFiles"))
            end
            if ~isfile(PreFilePath)
                writelines("%  Pre-run script for "+Filename,PreFilePath)
                writelines("% ---- Known Issues     -----",PreFilePath,'WriteMode','append');
                writelines("KnownIssuesID = "+char(34)+char(34)+";",PreFilePath,'WriteMode','append');
                writelines("% ---- Pre-run commands -----",PreFilePath,'WriteMode','append');
                writelines(" ",PreFilePath,'WriteMode','append');
            end
            Path = PreFilePath;
        end

        function Path = CheckPostFile(testCase,Filename)
            PostFile = "Post"+replace(Filename,".mlx",".m");
            PostFilePath = fullfile(currentProject().RootFolder,"SoftwareTests","PostFiles",PostFile);
            if ~isfolder(fullfile(currentProject().RootFolder,"SoftwareTests/PostFiles"))
                mkdir(fullfile(currentProject().RootFolder,"SoftwareTests/PostFiles"))
            end
            if ~isfile(PostFilePath)
                writelines("%  Post-run script for "+Filename,PostFilePath)
                writelines("% ---- Post-run commands -----",PostFilePath,'WriteMode','append');
                writelines(" ",PostFilePath,'WriteMode','append');
            end
            Path = PostFilePath;
        end

    end

end