function idARMASpectrumPlot(a, c, t, cov)
%idARMASpectrumPlot Plot the output spectrum for current estimate of ARMA
%model.
% Inputs:
%  a:    A polynomial estimate at time t.
%  c:    C polynomial estimate.
%  t:    The current time value.
%  cov:  Parameter vector covariance matrix.

%  Copyright 2015 The MathWorks, Inc.

persistent DataSrc TextObj CL

if t==0
   % Fetch the starting system (healthy state)
   sys = idpoly(a,[],c,'Ts',1/256); % original system for reference
   sys = setcov(sys, cov);
   sys2 = sys;  % second system whose parameters adapt (originally same as sys)
   % Generate a spectrum plot for the reference (sys) and adapting (sys2)
   % systems
   h = spectrumplot(gca,sys,sys2);
   % View peak response marker
   showCharacteristic(h,'PeakResponse')
   % View 2-std (99.7%) confidence region
   showConfidence(h, 3)
   % Add barrier line for visual inspection of condition
   line([10 80 80 150 150 804],[21.3*[1 1] 0.4*[1 1] -20*[1 1]],'color','k','LineWidth',2)
   % Fetch the data source corresponding to the adapting system sys2 and
   % cache it for updating.
   DataSrc = h.Responses(2).DataSrc; % the data source
   % Create a text object to display the "good" or "fault" tag
   TextObj = text(123, 19,' ','FontSize',14);
   axis([10 500 -40  30])
   grid on
   
   % Fetch the classifier
   CL = evalin('base','cl');
   
elseif rem(t,2)==0 % make only 100 updates for speed
   % Fetch the data source
   Model = DataSrc.Model;
   % Update the model parameters and covariance
   Model.a = a; Model.c = c; Model = setcov(Model, cov);
   % Update data source with the latest model. This causes the plot to
   % update.
   DataSrc.Model = Model;
   % Compute poles of the latest model
   p = esort(pole(noise2meas(Model)));
   % Predict the data class (good or faulty) using dominant poles of the
   % model
   [pr, score] = predict(CL, [real(p(1)),imag(p(1)),real(p(3)),imag(p(3))]);
   % Display the result of prediction. Call the results "tentative" if
   % the prediction score is close to the boundary of separation.
   add = '';
   if abs(score(1))<0.3
      add = ' (tentative)';
   end
   if strcmp(pr,'good')
      TextObj.String = ['Good',add];
      TextObj.Color = [0 .5 0];
   else
      TextObj.String = ['Fault',add];
      TextObj.Color = [0.9 0 0];
   end
end
