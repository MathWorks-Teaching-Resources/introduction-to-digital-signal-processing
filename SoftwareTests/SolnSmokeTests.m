classdef SolnSmokeTests < matlab.unittest.TestCase

    properties
        RootFolder
        isSolnOnPath
    end

    properties (ClassSetupParameter)
        Project = {char(currentProject().Name)};
    end

    properties (TestParameter)
        SolnScripts;
    end

    methods (TestParameterDefinition,Static)

        function SolnScripts = GetScriptName(Project)
            SolnScripts = dir(fullfile(currentProject().RootFolder,...
                "InstructorResources","Solutions","*.mlx"));
            SolnScripts = {SolnScripts.name};
        end

    end

    methods (TestClassSetup)

        function setUpPath(testCase,Project)

            try
                currentProject;
                testCase.RootFolder = currentProject().RootFolder;
                cd(testCase.RootFolder)
                testCase.isSolnOnPath = exist("Solutions","dir");
                if testCase.isSolnOnPath == 0
                    addpath(fullfile(testCase.RootFolder,"InstructorResources","Solutions"))
                end
            catch ME
                warning("Load project prior to run tests")
                rethrow(ME)
            end

            testCase.log("Running in " + version)

        end % function setUpPath

    end % methods (TestClassSetup)

    methods(Test)

        % Test that all the Script files have solution versions
        function ExistSolns(testCase)
            % files = dir(fullfile(testCase.RootFolder,"Scripts","*.mlx"));
            % for iTestSoln = 1:size(files)
            %     SolnFileName = extractBefore(files(iTestSoln).name,".mlx") + "Soln.mlx";
            %     SolnFilePath = fullfile(testCase.RootFolder,...
            %         "InstructorResources"+filesep+"Solutions",SolnFileName);
            %     assert(exist(SolnFilePath,"file"), "SolnTest:FileNotFound", SolnFileName + " doesn't exist");
            % end
            SolnFileName = "FilterDesignSoln.mlx";
            SolnFilePath = fullfile(testCase.RootFolder,...
                "InstructorResources"+filesep+"Solutions", SolnFileName);
            assert(exist(SolnFilePath,"file"), "SolnTest:FileNotFound", SolnFileName + " doesn't exist");
        end  
        function SmokeRun(testCase,SolnScripts)
            Filename = string(SolnScripts);
            SimpleSmokeTest(testCase,Filename);
        end
    end
    
    methods (Access = private)

        function SimpleSmokeTest(testCase,Filename)
            SolnFolder = fullfile(testCase.RootFolder,"InstructorResources","Solutions");
            cd(SolnFolder)
            disp(">> Running " + Filename);

            try
                run(fullfile(Filename));
            catch ME
                testCase.verifyTrue(false,ME.message);
            end
            
            
            % % Log the opened figures to the test reports
            % Figures = findall(groot,'Type','figure');
            % Figures = flipud(Figures);
            % if ~isempty(Figures)
            %     for f = 1:size(Figures,1)
            %         FigDiag = matlab.unittest.diagnostics.FigureDiagnostic(Figures(f));
            %         log(testCase,1,FigDiag);
            %     end
            % end
            % close all

            % for iTestSoln = 1:size(files)
            %     disp("Running " + files(iTestSoln).name + "...")
            %     run(files(iTestSoln).name)
            %     disp("Finished "+ files(iTestSoln).name)
            % end
        end
    end

    methods (TestClassTeardown)

        function closeAllFigure(testCase)
            close all % Close all figure
            bdclose all % Close all simulink
        end

        function RemovePath(testCase)
            if testCase.isSolnOnPath == 0
                rmpath(fullfile(testCase.RootFolder,"InstructorResources",...
                    "Solutions"))
            end
        end

    end % methods (TestClassTeardown)

end