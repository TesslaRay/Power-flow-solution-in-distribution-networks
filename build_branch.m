function [largepath, fork, branchnode, endnode] = build_branch(x,y)
% Función que construye los conjuntos de vectores necesarios para 
% el algoritmo Backward.
%   Input:
%       x: linedata
%       y: loaddata
%   Output:
%       largepath: rama más larga en la red radial
%       fork: nodos desde el nodo terminal hasta el nodo 'branching'
%       branchnode: nodos 'branching'
%       endnode: nodos terminales
    
    br = length(x(:,1)); % number of branch
    bs = length(y(:,1)); % number of buses 

    %Incidence matrix
    Incidence = zeros(br,bs);   % initilization for zero matrix
    for i = 1:br
        a = x(i,2);
        b = x(i,3);
        for j = 1:bs
            if a == j
                Incidence(i,j) = -1;
            end
            if b == j
                Incidence(i,j) = 1;
            end
        end
    end
    clearvars a b i j

    % End node
    endnode = [];
    for i = 1:bs
        aux = 0;
        for j = 1:br
            if Incidence(j,i) == -1
                aux = 1;
            end
        end

        if aux == 0
            endnode = [endnode; i] ;
        end
    end
    clearvars aux

    %branch
    branch = [];
    for i = 1:length(endnode)
        branch = [branch; endnode(i)];
    end

    for i = 1:length(endnode)
        aux2 = endnode(i);
        for j = 2:bs
            aux = find(Incidence(:,aux2) == 1);
            aux2= find(Incidence(aux,:) == -1);
            branch(i,j) = aux2;
            if aux2 == 1
                break
            end
        end
    end
    clearvars aux aux2 i j

    branchnode = [];
    for i = 1:length(endnode) - 1
        for j = i + 1:length(endnode)
            aux = intersect(branch(i,:),branch(j,:));
            branchnode = [branchnode aux(length(aux))];
        end
    end
    branchnode = unique(branchnode);
    clearvars aux i j

    for i = 1 : length(endnode)
        if length(branch) == length(find(branch(i,:) >0))
            in_largepath = i;
        end
    end
    clearvars i

    largepath = branch(in_largepath,:);
    branch([1 in_largepath],:)=branch([in_largepath 1],:);

    % order branch
    aux_branch = [largepath];
    for j = 1:10
        for i = 1:length(endnode) - 1
            if length(intersect(branch(i,:),branchnode)) < length(intersect(branch(i+1,:),branchnode));
                branch([i i+1],:)=branch([i+1 i],:);
            end
        end
    end

    endnode = flipud(branch(:,1));
    branchnode = flip(branchnode);

    for j = 2:length(branch(:,1))
        for i = 1:length(branch(1,:))    
            if branch(j,i) == branchnode(j-1)
                break
            end
            fork(j-1,i) = branch(j,i); 
        end
    end
    
end