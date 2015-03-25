% Pavel Trutman, pavel.trutman@fel.cvut.cz, March 2015
% 
% problemName - name of the minimalProblem; function specifies the problem
%   must have the same name
% benchmark - function, which defines benchmark procedures
% inputData - set of data on which we will test the solvers
% correctOutput - correct solutions of the problem for the inputData. It is
%   used to compare the correctness of the generated solvers.
% validationFunction - function called to evaluate the results

function [results] = gbs_Benchmark(problemName, benchmarkFunction, inputData, correctOutput, validationFunction)
  
  % get minimal problem definition
  problem = str2func(problemName);
  [eq, known, unknown, kngroups, cfg, algB] = problem();
  
  % parse input parameters
  if nargin < 3
    inputData = generateInputData(eq, known, unknown);
    correctOutput = [];
  end
  if nargin < 4
    validationFunction = @zeroPolynomials;
  end
  
  % enable benchmark mode
  cfg.benchmark = 1;
  
  % get benchmark definitions
  benchmarkConfig = benchmarkFunction(cfg);
  
  % do benchmarks
  fprintf('\nBENCHMARK STARTED\n');
  results = cell(length(benchmarkConfig), 1);
  for i = 1:length(benchmarkConfig)
    benchmark = benchmarkConfig{i};
    
    % print info
    fprintf('\n################################################################\n');
    fprintf(['\n', benchmark.info, '\n\n\n']);
    
    % create code
    gbs_CreateCode([problemName, '_' ,benchmark.abbrev], eq, known, unknown, kngroups, benchmark.cfg, algB);
    
    % update MATLAB cache to recognize new generated functions
    rehash;
    
    solver = str2func(['solver_', problemName, '_' ,benchmark.abbrev]);
    
    % call solver for all inputData and save results
    results{i}.solution = cell(size(inputData, 1), 1);
    results{i}.benchData = cell(size(inputData, 1), 1);
    results{i}.time = zeros(size(inputData, 1), 1);
    for j = 1:size(inputData, 1)
      tic
      [results{i}.solution{j}, results{i}.benchData{j}] = solver(inputData{j});
      results{i}.time(j) = toc;
    end
    
    % get errors of solutions
    results{i}.err = validationFunction(inputData, correctOutput, results{i}.solution, results{i}.benchData);
    
  end

end