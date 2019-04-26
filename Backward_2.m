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
          4    2      5     0.1640    0.1565
          ];
      
 %Load data of 33 Node Radial Distribution Test System
 %         Bus    -----Load-----     Q
 %         No.     (kW)   (kVAr)  Injected
loaddata =[ 1       0         0  	  0
            2       100       60 	  0
            3       90        40      0
            4       120       80	  0
            5       90        40      0             
          ];

% P.U
MVAb = 100;                 % base MVA
KVb  = 11;                  % base kV
Zb   = (KVb^2)/MVAb;        % base impedance
      

Z = complex(linedata(:,4),linedata(:,5))/Zb;
S = complex(loaddata(:,2),loaddata(:,3))/(1000*MVAb);

branch = [4,3,2,1;5,2,1,0];
branchnode = [2];

Vb_k = ones(5,1);
Vb_k1 = ones(5,1);

e = 1E-8;                   % tolerancia

Ish(4) = complex(1,0);
Ish(5) = complex(1,0);

for IT = 1:10
    
    Zsh = conj(Vb_k.^2./S);
    
    for i = 1:length(branch(1,:)) - 1
%         branch(1,i)
        
        if branch(1,i) == 4
%             disp('nodo terminal')
            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i));

            Vb_k(branch(1,i)) = Ish(branch(1,i))*Zsh(branch(1,i));
            
        elseif branch(1,i) == 2
%             disp('nodo branch')
            
            Vb_k(branch(1,i)) = Vb_k(branch(1,i - 1)) + Z(branch(1,i))*Ibr(branch(1,i));
            
            Ibr(4) = Ish(5);

            Vb_k(5) = Ish(5)*Zsh(5);
            
            Vprima = Vb_k(5) + Z(4)*Ibr(4);           
            
            Ish(5) = Vb_k(2)*Ish(5)/Vprima;
            
            Vb_k(5) = Ish(5)*Zsh(5);

            Ibr(4) = Ish(5);
            
            Ish(branch(1,i)) = Vb_k(branch(1,i))/Zsh(branch(1,i));
                        
            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i)) + Ibr(branch(1,i)) + Ibr(4);

        else
%             disp('nodo normal')
            
            Vb_k(branch(1,i)) = Vb_k(branch(1,i - 1)) + Z(branch(1,i))*Ibr(branch(1,i));

            Ish(branch(1,i)) = Vb_k(branch(1,i))/Zsh(branch(1,i));

            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i)) + Ibr(branch(1,i));
        end

    end
    
    % AJUSTE
 %     disp('Ajuste')

    Vb_k(1) = Vb_k(2) + Z(1)*Ibr(1);
    
    Ish(4) = complex(1,0)*Ish(4)/Vb_k(1);
    
    for x = 1:length(branch(1,:))
%         branch(1,x)
                
        if branch(1,x) == 4
%             disp('ajuste nodo terminal')
                    
            Vb_k1(branch(1,x),1) = Zsh(branch(1,x))*Ish(branch(1,x));
                    
            Ibr(branch(1,x) - 1,1) = Ish(branch(1,x));
        elseif branch(1,x) == 2
%             disp('ajuste nodo branch')
            
            Vb_k1(branch(1,x)) = Vb_k1(branch(1,x - 1)) + Z(branch(1,x))*Ibr(branch(1,x));
            
            Ibr(4) = Ish(5);

            Vb_k1(5) = Ish(5)*Zsh(5);
            
            Vprima = Vb_k1(5) + Z(4)*Ibr(4);           
            
            Ish(5) = Vb_k1(2)*Ish(5)/Vprima;
            
            Vb_k1(5) = Ish(5)*Zsh(5);

            Ibr(4) = Ish(5);
            
            Ish(branch(1,x)) = Vb_k1(branch(1,x))/Zsh(branch(1,x));
                        
            Ibr(branch(1,x) - 1,1) = Ish(branch(1,x)) + Ibr(branch(1,x)) + Ibr(4);
            
        elseif branch(1,x) == 1
%             disp('ajuste nodo inicial')
                    
            Vb_k1(branch(1,x)) = Vb_k1(branch(1,x - 1)) + Z(branch(1,x))*Ibr(branch(1,x));
                    
        else
%             disp('ajuste nodo normal')
                    
            Vb_k1(branch(1,x)) = Vb_k1(branch(1,x - 1)) + Z(branch(1,x))*Ibr(branch(1,x));
                    
            Ish(branch(1,x)) = Vb_k1(branch(1,x))/Zsh(branch(1,x));
                    
            Ibr(branch(1,x) - 1,1) = Ish(branch(1,x)) + Ibr(branch(1,x));
                    
        end
    end
    
%     abs(Vb_k - Vb_k1) < e
    if abs(Vb_k - Vb_k1) < e
        break
    end
    
    Vb_k = Vb_k1;
    
end


IT
Vfinal=[abs(Vb_k) angle(Vb_k)*180/pi]
