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
          4    4      5     0.3811    0.1941    
          5    5      6     0.8190    0.7070    
          6    6      7     0.1872    0.6188
          7    2      8     0.1640    0.1565    
          8    8      9     1.5042    1.3554  
          9    9     10     0.4095    0.4784   
          10  10     11     0.7089    0.9373 
          ];
      
 %Load data of 33 Node Radial Distribution Test System
 %         Bus    -----Load-----     Q
 %         No.     (kW)   (kVAr)  Injected
loaddata =[ 1       0         0  	  0
            2       100       60 	  0
            3       90        40      0  	
            4       120       80	  0  
            5       60        30	  0  
            6       60        20      0 
            7       200       100	  0
            8       90        40      0
            9       90        40      0
           10       90        40      0
           11       90        40      0
          ];

% P.U
MVAb = 100;                 % base MVA
KVb  = 11;                  % base kV
Zb   = (KVb^2)/MVAb;        % base impedance
      
Z = complex(linedata(:,4),linedata(:,5))/Zb;
S = complex(loaddata(:,2),loaddata(:,3))/(1000*MVAb);

branch = [7,6,5,4,3,2,1; 11,10,9,8,2,1,0];
branchnode = [2];
endnode = [7,11];

Vb_k = ones(length(loaddata(:,1)),1);
Vb_k1 = ones(length(loaddata(:,1)),1);

e = 1E-4;                   % tolerancia

Ish(endnode) = complex(1,0);

for IT = 1:100
    
    Zsh = conj(Vb_k.^2./S);
    
    for i = 1:length(branch(1,:)) - 1
%         branch(1,i)
        
        if branch(1,i) == branch(1,1)
%             disp('nodo terminal')
            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i));

            Vb_k(branch(1,i)) = Ish(branch(1,i))*Zsh(branch(1,i));
            
        elseif branch(1,i) == branchnode(1)
%             disp('nodo branch')
            
            Vb_k(branch(1,i)) = Vb_k(branch(1,i - 1)) + Z(branch(1,i))*Ibr(branch(1,i));
            
            Ibr(branch(2,1) - 1) = Ish(branch(2,1));

            Vb_k(branch(2,1)) = Ish(branch(2,1))*Zsh(branch(2,1));
            
            for j = 2:length(branch(2,:))
                                
                if branch(2,j) == branchnode(1)
                    break
                end
                
                Vb_k(branch(2,j)) = Vb_k(branch(2,j - 1)) + Z(branch(2,j))*Ibr(branch(2,j));

                Ish(branch(2,j)) = Vb_k(branch(2,j))/Zsh(branch(2,j));

                Ibr(branch(2,j) - 1,1) = Ish(branch(2,j)) + Ibr(branch(2,j));
                                
            end
    
            Vprima = Vb_k(branch(1,1) + 1) + Z(branch(1,1))*Ibr(branch(1,1));
            
            Ish(branch(2,1)) = Vb_k(branchnode(1))*Ish(branch(2,1))/Vprima;
            
            Vb_k(branch(2,1)) = Ish(branch(2,1))*Zsh(branch(2,1));

            Ibr(branch(2,1) - 1) = Ish(branch(2,1));
            
            for j = 2:length(branch(2,:))
%                 branch(2,j)
                
                if branch(2,j) == 2
                    break
                end
                           
                Vb_k(branch(2,j)) = Vb_k(branch(2,j - 1)) + Z(branch(2,j))*Ibr(branch(2,j));

                Ish(branch(2,j)) = Vb_k(branch(2,j))/Zsh(branch(2,j));

                Ibr(branch(2,j) - 1,1) = Ish(branch(2,j)) + Ibr(branch(2,j));
                                
            end
            
            Ish(branch(1,i)) = Vb_k(branch(1,i))/Zsh(branch(1,i));
                        
            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i)) + Ibr(branch(1,i)) + Ibr(7);

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
    
    Ish(branch(1,1)) = complex(1,0)*Ish(branch(1,1))/Vb_k(1);
    
    for x = 1:length(branch(1,:))
%         branch(1,x)
                
        if branch(1,x) == branch(1,1)
%             disp('ajuste nodo terminal')
                    
            Vb_k1(branch(1,x),1) = Zsh(branch(1,x))*Ish(branch(1,x));
                    
            Ibr(branch(1,x) - 1,1) = Ish(branch(1,x));
            
        elseif branch(1,x) == branchnode(1)
%             disp('ajuste nodo branch')
            
            Vb_k1(branch(1,x)) = Vb_k1(branch(1,x - 1)) + Z(branch(1,x))*Ibr(branch(1,x));
                        
            Ibr(10) = Ish(11);

            Vb_k1(11) = Ish(11)*Zsh(11);
            
            for j = 2:length(branch(2,:))
                
                
                if branch(2,j) == 2
                    break
                end
%                 branch(2,j)
                Vb_k1(branch(2,j)) = Vb_k1(branch(2,j - 1)) + Z(branch(2,j))*Ibr(branch(2,j));

                Ish(branch(2,j)) = Vb_k1(branch(2,j))/Zsh(branch(2,j));

                Ibr(branch(2,j) - 1,1) = Ish(branch(2,j)) + Ibr(branch(2,j));
                                
            end
            
            Vprima = Vb_k1(8) + Z(7)*Ibr(7);           
            
            Ish(11) = Vb_k1(2)*Ish(11)/Vprima;
            
            Vb_k1(11) = Ish(11)*Zsh(11);

            Ibr(10) = Ish(11);
            
            for j = 2:length(branch(2,:))
%                 branch(2,j)
                
                if branch(2,j) == 2
                    break
                end
                           
                Vb_k1(branch(2,j)) = Vb_k1(branch(2,j - 1)) + Z(branch(2,j))*Ibr(branch(2,j));

                Ish(branch(2,j)) = Vb_k1(branch(2,j))/Zsh(branch(2,j));

                Ibr(branch(2,j) - 1,1) = Ish(branch(2,j)) + Ibr(branch(2,j));
                                
            end
            
            Ish(branch(1,i)) = Vb_k1(branch(1,i))/Zsh(branch(1,i));
                        
            Ibr(branch(1,i) - 1,1) = Ish(branch(1,i)) + Ibr(branch(1,i)) + Ibr(7);
            
        elseif branch(1,x) == branch(1,length(branch(1,:)))
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
