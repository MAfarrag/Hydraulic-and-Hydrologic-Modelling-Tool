%Hydrological Model HBV-96
%Implementation by Juan Chacon
%UNESCO-IHE
%Original source Lindström 1997.

function [QNew, St] = HBV(p,v,St,AREA,timebases) 
% input arguments of the function are parameters (p), inputs (v) and states (St)
%% Data load
%{
v = Input vector
p = Parameter vector
St = State vector
x = Aditional parameters (values that multiply old states in the model)

Input variables 
P = Total precipitation v(1)
T = actual temperature v(2)
ETF = Total potential evapotranspiration v(3) % input
TM = daily long term mean temperature v(4) %input

Parameter Set
TT = Limit temperature for rain/snow precipitation p(1)
TTI = temperature treshold for linear mix of snow/rain precipitation p(2)
TTM = Limit temperature for melting p(3)
CFMAX = Degree day factor (measures the temperature variation along the
day) p(4)
FC = Field Capacity p(5)
ECORR = Evapotranspiration corrector factor p(6)
EP = Long term mean potential evapotranspiration p(7)
LP = Soil moisture value where soil moisture reaches maximum potential
evapotranspiration p(8)
K = Upper zone response coefficient p(9)
K1 = Lowe zone response coefficient p(10)
ALPHA = upper zone runoff coefficient p(11)
BETA = Controls the contribution of the increase in the soil moisture or
to the response function p(12)
CWH = Maximum amount of water that can be stored in snow pack p(13)
CFR = Refreezing factor p(14)
CFLUX = Capilar flux p(15)
PERC = Percolation p(16)
RFCF = Rainfal correction factor p(17)
SFCF = Snowfall correction factor p(18)


Non optimised parameters
TFAC = Time factor p(19) = dt/86400
AREA = Catchment area p(20) [km²]

Internal States -> storages
SPOld = intial estimation of snow pack St(1)
SMOld = Soil Moisture in previous time step St(2)
UZOld = Upper zone storage previous time step St(3)
LZOld = Lower zone storage previous time step St(4)
WCOld = Water content in snow pack St(5)
%}


%inputs v(1,2)
P = v(1,1); % Precipitation [mm]
T = v(1,2); % Temperature [C]
EP = v(1,3); % Long terms (monthly) Evapotranspiration [mm]
TM = v(1,4); % Long term (monthly) average temperature [C]

% Parameters vector of p(1,20)
TT = p(1);
TTI = p(2);
TTM = p(3);
CFMAX = p(4);
FC = p(5);
ECORR = p(6);
ETF = p(7);
LP = p(8);
K = p(9);
K1 = p(10);
ALPHA = p(11);
BETA = p(12);
CWH = p(13);
CFR = p(14);
CFLUX = p(15);
PERC = p(16);
RFCF = p(17);
SFCF = p(18);

%Non optimised parameters
if timebases==0 %daily
    TFAC = 1;
    unitconst=86.4;
else              % hourly
    TFAC = 1/24;
    unitconst=3.6;
end
%AREA = 2900;

% States vector St(1,5)
SPOld = St(1); % Snow Pack
SMOld = St(2); % Soil Moisture
UZOld = St(3); % Upper Zone
LZOld = St(4); % Lower Zone
WCOld = St(5); % Water Content in Snow Pack

%% Inputs Routine
%{
Input: Here is defined the ammount of rain or snow precipitated over the
basin
T = Actual temperature in the catchment
TT = Temperature limit for rain/snow precipitation
TTI = temperature treshold for linear mix of snow/rain precipitation
%}

if T<=TT-TTI/2; % if temerature is below the snow/rain treshold,
                % then all precipitation becomes snowfall (SF)
  RF = 0.0;
  SF = P*SFCF;
else
  if(T>=TT+TTI/2.0); % if the temperature is over the snow/rain treshold,
                        % the all precipitation becomes rainfall (RF)
    RF = P*RFCF;
    SF = 0.0;
  else %Otherwise, the amount of snow and rain precipitated is a linear combination of both
    RF =      2.0*(T-TT)/TTI  * P * RFCF;
    SF = (1.0-2.0*(T-TT)/TTI) * P * SFCF;
  end
end

%% Snow Routine
%{
TTM = Limit temperature for melting
CFMAX = Degree day factor (measures the temperature variation along the
day)
TFAC = Temperature factor
SP, SPOld, SPNew = frozen part of snowpack
SF = Snowfall (comes from input)
CFR = Refreezing factor
%}

if (T>TTM) % if temeperature is higher than limit temperature 
            % for melting (snow is melting)

      if (CFMAX*TFAC*(T-TTM)<SPOld+SF); % Evaluate if the snow melt is higher
                                        % than the designed fraction of the snow pack
          MELT = CFMAX*TFAC*(T-TTM); % if yes, then the thaw is equivalent 
                                     % to the one described by the physical process
        else
          MELT = SPOld+SF; % Otherwise, the snow melt is going to be considered
                           % as a fraction of the snow pack, plus the actual snowfall
      end
      SPNew = SPOld+SF-MELT;
      WCInt = WCOld+MELT+RF;

  else % if the temperature is below the critical treshold

      if (CFR*CFMAX*TFAC*(TTM-T)<WCOld+RF) % this is a conditional for the
                                            % refreezing of water stored in the snow
          REFR = CFR*CFMAX*TFAC*(TTM-T); % if the temperature is too low, it
                                            % will freeze again
        else
          REFR = WCOld+RF; % otherwise the frozen water will be the same
                            % as the previous stored water plus the rainfall
      end
      SPNew = SPOld+SF+REFR;
      WCInt = WCOld-REFR+RF;
end

if (WCInt>CWH*SPNew) %if there is more water than snow holding capacity then
    IN = WCInt-CWH*SPNew; %There is going to be infiltration
    WCNew = CWH*SPNew; % the snow will be saturated by liquid water
    
  else 
    IN = 0.0; %if there is no saturation, then there is no infiltration to soil
    WCNew = WCInt; % the amount of water stored in the snow will be the same as before
end

%% Soil Routine
%{
FC = Maximum soil moisture content
IN = Infiltration -> defined by the snow melt if considered````
BETA = Controls the contribution of the increase in the soil moisture or
to the response function
ETF = Total potential evapotranspiration
TM = daily long term mean temperature
ECORR = Evapotranspiration height corrector factor
EP = Long term mean potential evapotranspiration
EPInt = Adjusted potential evapotranspiration
LP = Soil moisture value where soil moisture reaches maximum potential evapotranspiration
SMOld = Soil Moisture
CFLUX = Capilar flux
UZOld = Upper zone storage previous time step
%}

R = ((SMOld/FC)^ BETA) * IN; %Runoff from soil
EPInt = (1.0+ETF*(T-TM))*ECORR*EP; % Monthly coefficient for evapotranspiration

if (SMOld < (LP*FC)); % conditional to check if the old soil moisture is
                        % greater than the limit for potential evapotranspiration
    EA = TFAC*SMOld/(LP*FC)*EPInt; %actual evapotranspiration when there is
                                    % no moisture to reach the potential evapotranspiration
  else 
    EA = TFAC*EPInt; %actual evapotranspiration with total moisture availability
end

if (TFAC*CFLUX*(1.0-(SMOld/FC))<UZOld); % if the upper zone storage is greater 
                                    %than the potential capilar flow, then is going to be caiplar flow
    CF = TFAC*CFLUX*(1.0-(SMOld/FC)); %capilar flow definition
  else
    CF = UZOld; %if the storage in the upper zone is lower than the flow
                % itself, it will remain as the previous value for the UZ storage
end

SMNew = SMOld+(IN-R)+CF-EA; %soil moisture content after runoff and evapotranspiration and rainfall
UZInt1 = UZOld+R-CF; %upper zone storage.

%% Response Routine
%{
%PERC = Percolation
%LZOld = Lower zone storage
%K = Upper zone response coefficient
%K1 = Lowe zone response coefficient
%ALPHA = upper zone runoff coefficient
%AREA = Catchment area
%}

if (TFAC*PERC<UZInt1) % Check for percolation. if the level in the upper zone
                        %is higher, then the lower zone is going to be affected by this
    LZInt1 = LZOld+TFAC*PERC; % the definition of the lower zone is equal to
                                % the previous one, plus the percolation from the upper zone
  else 
    LZInt1 = LZOld+UZInt1; % otherwise, the lower zone is going to be defined by the
                            % actual upper zone plus the previous lower zone response
end

if (UZInt1>TFAC*PERC) % The same procedure as before, but now considering the upper box
    UZInt2 = UZInt1-TFAC*PERC; %definition of the storage due to losses on percolation
  else
    UZInt2 = 0.0; % if the upper zone storage is not enough, then all goes
                    %to percolation, and is reflected in the lower response box
end

Q0 = K*(UZInt2^( 1.0+ALPHA)); %definition of outflow from upper reponse box
Q1 = K1*LZInt1; % definition of outflow from lower response box

UZNew = UZInt2-TFAC*Q0; %new value for the upper zone storage
LZNew = LZInt1-TFAC*Q1; % new value for the lower zone storage

QNew = AREA*(Q0+Q1)/unitconst; % total outflow

%% State vector  updater save
%{
% WCOld = WCNew;
% SMOld = SMNew;
% UZOld = UZNew;
% LZOld = LZNew;
% SPOld = SPNew;
%}

St(1) = SPNew;
St(2) = SMNew;
St(3) = UZNew;
St(4) = LZNew;
St(5) = WCNew;

end
