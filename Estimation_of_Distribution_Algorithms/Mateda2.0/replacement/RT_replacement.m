function [NewPop,NewFunVal] = RT_replacement(Pop,SelPop,SampledPop,FunVal,SelFunVal,SampledFunVal,replacement_params)
% [NewPop,NewFunVal] = RT_replacement(Pop,SelPop,SampledPop,FunVal,SelFunVal,SampledFunVal,replacement_params)
% RT_replacement            Creates a new population (NewPop) applying restricted tournament replacement. For each
%                           newly generated individual,  first a subset  of (window) individuals from
%                           the current population is selected. The individual genotypically closest (square
%                           difference) to the candidate individual is found. The individual with highest evaluation
%                           remains in the population. 
%                           This method is appropriate for single objective optimization.
% INPUTS 
% Pop:                                 Current population
% SelPop:                              Current selected population
% SampledPop:                          Population sampled from the probabilistic model
% CurrentFunVal:                       A matrix of function evaluations, one vector of m objectives for each individual
% OUTPUTS
% NewPop                        : New Population
% NewFunVal                     : Evaluations of the new population
% window = replacement_params{1}(1): Subset of solutions considered in the comparison. 
%
% Last version 8/26/2008. Roberto Santana (roberto.santana@ehu.es)       


find_bestinds_method =  char(cellstr(replacement_params{1}(1)));
window = cell2num(replacement_params{1}(2)); 
PopSize = size(Pop,1);
SelPopSize = size(SelPop,1);
SampledPopSize = size(SampledPop,1);

NewPop = Pop;
NewFunVal = FunVal;



Agregated_Pop = [Pop;SampledPop];
Agregated_PopFunVal = [FunVal;SampledFunVal];
nans = sum(isnan(Agregated_PopFunVal(:,1)));

[Ind]  = eval([find_bestinds_method,'(Agregated_Pop,Agregated_PopFunVal)']);  %The k best individuals are taken from Pop
iNans = Ind(1:nans);
Ind(1:(PopSize+SampledPopSize - nans) ) = Ind((nans+1):(PopSize+SampledPopSize));
Ind((PopSize+SampledPopSize - nans +1):(PopSize+SampledPopSize)) = iNans;

[ex sorting] = ismember(1:(PopSize+SampledPopSize),Ind);
indSampled = sorting((PopSize+1):(PopSize+SampledPopSize));
indPop = sorting(1:PopSize);

tonorm = repmat((max(Pop) - min(Pop)),window,1);
for i=1:SampledPopSize,%PopSize
  auxperm = randperm(PopSize);
  candidates =  auxperm(1:window);
  auxsubpop = repmat(SampledPop(i,:),window,1);
   

  aux = ((auxsubpop - NewPop(candidates,:))./ tonorm);
  
  [minval,minpos] = min(sum(aux'.^2));
  closest_sol = candidates(minpos);
   
%   if SampledFunVal(i) >= NewFunVal(closest_sol)
%     NewPop(closest_sol,:) = SampledPop(i,:);
%     NewFunVal(closest_sol) = SampledFunVal(i);     
%   end

   if indSampled(i) <= indPop(closest_sol)
     NewPop(closest_sol,:) = SampledPop(i,:);
     NewFunVal(closest_sol) = SampledFunVal(i);     
   end
end

return
 
 
 