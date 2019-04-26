clc
clear all

global linedata loaddata
% line data of 33 Node Radial Distribution Test System
%      Branch  Sn.   Rc.      Line      Line
%         No   Nd    Nd    Resistance Reactance
linedata =[          
          1    1      2     0.0922    0.0470   
          2    2      3     0.4930    0.2511    
          3    3      4     0.3660    0.1864  
          ];
      
 %Load data of 33 Node Radial Distribution Test System
 %         Bus    -----Load-----     Q
 %         No.     (kW)   (kVAr)  Injected
loaddata =[ 1       0         0  	  0
            2       100       60 	  0
            3       90        40      0
            4       120       80	  0            
          ];

% P.U
MVAb = 100;                 % base MVA
KVb  = 11;                  % base kV
Zb   = (KVb^2)/MVAb;        % base impedance
      

Z = complex(linedata(:,4),linedata(:,5))/Zb;
S = complex(loaddata(:,2),loaddata(:,3))/(1000*MVAb);

branch = [4,3,2,1];

Vb_k = ones(4,1);
Vb_k1 = ones(4,1);

e = 1E-8;                   % tolerancia

Ish(4) = complex(1,0);

for IT = 1:10
    
    Zsh = conj(Vb_k.^2./S);
    
    for i = 1:length(branch) - 1
%         branch(i)
        if branch(i) == 4
%             disp('nodo terminal')

            Ibr(branch(i) - 1,1) = Ish(branch(i));

            Vb_k(branch(i)) = Ish(branch(i))*Zsh(branch(i));

        else
%             disp('nodo normal')

            Vb_k(branch(i)) = Vb_k(branch(i - 1)) + Z(branch(i))*Ibr(branch(i));

            Ish(branch(i)) = Vb_k(branch(i))/Zsh(branch(i));

            Ibr(branch(i) - 1,1) = Ish(branch(i)) + Ibr(branch(i));

        end
    end
    
%     disp('Ajuste')
    % AJUSTE
    Vb_k(1) = Vb_k(2) + Z(1)*Ibr(1);

%     how do I adjust the node voltage and the branch current?

    Ish(4) = complex(1,0)*Ish(4)/Vb_k(1);
            
    for x = 1:length(branch)
%         branch(x)
                
        if branch(x) == 4
%             disp('ajuste nodo terminal')
                    
            Vb_k1(branch(x),1) = Zsh(branch(x))*Ish(branch(x));
                    
            Ibr(branch(x) - 1,1) = Ish(branch(x));
   
        elseif branch(x) == 1
%             disp('ajuste nodo inicial')
                    
        Vb_k1(branch(x)) = Vb_k1(branch(x - 1)) + Z(branch(x))*Ibr(branch(x));
                    
        else
%             disp('ajuste nodo normal')
                    
            Vb_k1(branch(x)) = Vb_k1(branch(x - 1)) + Z(branch(x))*Ibr(branch(x));
                    
            Ish(branch(x)) = Vb_k1(branch(x))/Zsh(branch(x));
                    
            Ibr(branch(x) - 1,1) = Ish(branch(x)) + Ibr(branch(x));
                    
        end
    end
       
    if abs(Vb_k - Vb_k1) < e
        break
    end
    
    Vb_k = Vb_k1;
end

IT
Vfinal=[abs(Vb_k) angle(Vb_k)*180/pi]





