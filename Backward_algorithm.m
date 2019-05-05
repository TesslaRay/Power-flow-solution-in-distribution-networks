% Radial power flow

clc;
clear all;

global linedata loaddata
% line data of 33 Node Radial Distribution Test System
%      Branch  Sn.   Rc.      Line      Line
%         No   Nd    Nd    Resistance Reactance
linedata =[          
          1    1      2     0.0922    0.0470   
          2    2      3     0.4930    0.2511    
          3    3      4     0.3660    0.1864  
          4    4      5     0.3811    0.1941    
          5    5      6     0.8190    0.7070    
          6    6      7     0.1872    0.6188   
          7    7      8     0.7114    0.2351 
          8    8      9     1.0300    0.7400   
          9    9      10    1.0440    0.7400   
         10    10     11    0.1966    0.0650   
         11    11     12    0.3744    0.1238   
         12    12     13    1.4680    1.1550   
         13    13     14    0.5416    0.7129   
         14    14     15    0.5910    0.5260    
         15    15     16    0.7463    0.5450   
         16    16     17    1.2890    1.7210   
         17    17     18    0.7320    0.5740  
         18     2     19    0.1640    0.1565    
         19    19     20    1.5042    1.3554  
         20    20     21    0.4095    0.4784   
         21    21     22    0.7089    0.9373    
         22     3     23    0.4512    0.3083    
         23    23     24    0.8980    0.7091  
         24    24     25    0.8960    0.7011   
         25     6     26    0.2030    0.1034   
         26    26     27    0.2842    0.1447    
         27    27     28    1.0590    0.9337    
         28    28     29    0.8042    0.7006   
         29    29     30    0.5075    0.2585  
         30    30     31    0.9744    0.9630   
         31    31     32    0.3105    0.3619   
         32    32     33    0.3410    0.5302
         ];
     
%Load data of 33 Node Radial Distribution Test System
%           Bus    -----Load-----     
%           No.     (kW)    (kVAr)  
loaddata =[ 1       0         0  	  
            2       100       60 	  
            3       90        40        	
            4       120       80	    
            5       60        30	    
            6       60        20       
            7       200       100	  
            8       200       100	   
            9       60        20      	
            10      60        20 	  
            11      45        30 	  
            12      60        35       
            13      60        35       
            14      120       80       
            15      60        10       
            16      60        20       
            17      60        20       
            18      90        40       
            19      90        40       
            20      90        40       
            21      90        40      
            22      90        40       
            23      90        50      
            24      420       200	  
            25      420       200	  
            26      60        25        
            27      60        25       
            28      60        20      
            29      120       70      
            30      200       600	  
            31      150       70        
            32      210       100	  
            33      60        40      
            ];

% P.U
MVAb = 100;                 % base MVA
KVb  = 11;                  % base kV
Zb   = (KVb^2)/MVAb;        % base impedance

% Impedance
Z = complex(linedata(:,4),linedata(:,5))/Zb;

% Power
S = complex(loaddata(:,2),loaddata(:,3))/(1000*MVAb);

Pd = loaddata(:,2)';
Qd = loaddata(:,3)';
Pdt = sum(Pd);
Qdt = sum(Qd);
Pt = sum(loaddata(:,2))/(1000*MVAb);      % total active power 
Qt = sum(loaddata(:,3))/(1000*MVAb);      % total reactive power

[largepath, fork, branchnode, endnode] = build_branch(linedata,loaddata);

Vb_k = ones(length(loaddata(:,1)),1);
Vb_k1 = ones(length(loaddata(:,1)),1);
Ibr = zeros(length(loaddata(:,1)) - 1,1);

e = 1E-6;                   % tolerance

Ish(endnode) = complex(1,0);

for IT = 1:100
    
    Zsh = conj(Vb_k.^2./S);
    
    b = 1;
    for i = 1:length(largepath(1,:)) - 1
        
        if largepath(1,i) == largepath(1)
            Ibr(largepath(i) - 1,1) = Ish(largepath(i));

            Vb_k(largepath(i)) = Ish(largepath(i))*Zsh(largepath(i));
            
        elseif largepath(i) == branchnode(b)
            
            Vb_k(largepath(i)) = Vb_k(largepath(i - 1)) + Z(largepath(i))*Ibr(largepath(i));
            
            Ibr(fork(b,1) - 1) = Ish(fork(b,1));

            Vb_k(fork(b,1)) = Ish(fork(b,1))*Zsh(fork(b,1));
            
            for j = 2:length(fork)
                
                if fork(b,j) == 0
                    j = j - 1;
                    break
                end
                
                Vb_k(fork(b,j)) = Vb_k(fork(b,j - 1)) + Z(fork(b,j))*Ibr(fork(b,j));

                Ish(fork(b,j)) = Vb_k(fork(b,j))/Zsh(fork(b,j));

                Ibr(fork(b,j) - 1) = Ish(fork(b,j)) + Ibr(fork(b,j));
            end
    
            Vprima = Vb_k(fork(b,j)) + Z(fork(b,j) - 1)*Ibr(fork(b,j) - 1);
            
            k = Vb_k(largepath(i))/Vprima;           
            
            for j = 1:length(fork)
               
                if fork(b,j) == 0
                    j = j - 1;                    
                    break
                end
                
                Vb_k(fork(b,j)) = Vb_k(fork(b,j)) * k;

                Ish(fork(b,j)) = Ish(fork(b,j))* k;

                Ibr(fork(b,j) - 1) = Ibr(fork(b,j) - 1) * k;
                                
            end
            
            Ish(largepath(i)) = Vb_k(largepath(i))/Zsh(largepath(i));
                        
            Ibr(largepath(i) - 1) = Ish(largepath(i)) + Ibr(largepath(i)) + Ibr(fork(b,j) - 1);
            b = b + 1;
        else
            
            Vb_k(largepath(i)) = Vb_k(largepath(i - 1)) + Z(largepath(i))*Ibr(largepath(i));

            Ish(largepath(i)) = Vb_k(largepath(i))/Zsh(largepath(i));

            Ibr(largepath(i) - 1) = Ish(largepath(i)) + Ibr(largepath(i));
        end

    end
    
    % Correction
    Vb_k(1) = Vb_k(2) + Z(1)*Ibr(1);
    
    b = 1;
    k = complex(1,0)/Vb_k(1);
    
    Vb_k1 = Vb_k * k;
    Ish = Ish * k;
    Ibr = Ibr * k;
    
    if abs(Vb_k - Vb_k1) < e
        break
    end
    
    Vb_k = Vb_k1;
    
end

IT;

Vfinal=[abs(Vb_k) angle(Vb_k)*180/pi];
Ifinal=[abs(Ibr) angle(Ibr)*180/pi];

% Losses
PL = 0;
QL = 0;
for i=1:32
    Pl(i)=(Ifinal(i).^2)*linedata(i,4)/Zb;
    Ql(i)=(Ifinal(i).^2)*linedata(i,5)/Zb;
    PL = PL + Pl(i);
    QL = QL + Ql(i);
end

PL=(PL)*100000;
QL=(QL)*100000;

for i=1:33
    if i==1
        Pg(i) = Pt*100000 + PL;
        Qg(i) = Qt*100000 + QL;
    else
        Pg(i) = 0;
        Qg(i) = 0;
    end
end
Pgen = Pg';
Qgen = Qg';

Vm = Vfinal(:,1) ;
deltad = Vfinal(:,2);

Pgent = sum(Pg);
Qgent = sum(Qg);


% Results
tech=('             Radial Distribution Load Flow Solution   ');
disp(tech)
disp('=================================================================')
head =['    Bus  Voltage  Angle    ------Load------    ---Substation--- '
       '    No.  Mag.     Degree     kW       kVAr       kW       kVAr  '
       '                                                                '];
disp(head)
disp('================================================================= ')

for n=1:33
      fprintf(' %5g', n), fprintf(' %7.4f', Vm(n)),
     fprintf(' %8.4f', deltad(n)), fprintf(' %9.4f', Pd(n)),
     fprintf(' %9.4f', Qd(n)), fprintf(' %10.4f', Pgen(n)),
     fprintf(' %10.4f \n', Qgen(n))
end

disp('=================================================================') 
    fprintf('      \n'), fprintf('    Total              ')
    fprintf(' %9.4f', Pdt), fprintf(' %9.4f', Qdt),
    fprintf(' %10.4f', Pgent), fprintf(' %10.4f\n\n\n', Qgent)

    
fprintf('Número de iteraciones: %5g\n', IT)