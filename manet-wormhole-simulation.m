clear; clc; close all;


numNodes = 20; areaSize = 500; txRange = 150;
nodeSpeed = 15; 


wh1Node = 5;
wh2Node = 13;


X = rand(1, numNodes) * areaSize;
Y = rand(1, numNodes) * areaSize;


totalAttempts = 0;
wormholeAttacks = 0;
wormholeRateHistory = [];

% Animasyon Penceresi
fig = figure('Name', 'AODV Wormhole Simulation', 'Position', [100, 100, 700, 700]);

disp('--- Simulation Started ---');
disp('The simulation will stop when you close the window.');

while ishandle(fig) 
    clf(fig); hold on; grid on; axis([0 areaSize 0 areaSize]);
    title('MANET Wormhole Attack');
    
    totalAttempts = totalAttempts + 1; 

    sourceNode = randi(numNodes);
    while ismember(sourceNode, [wh1Node, wh2Node])
        sourceNode = randi(numNodes);
    end
    destNode = randi(numNodes);
    while isequal(destNode, sourceNode) || ismember(destNode, [wh1Node, wh2Node])
        destNode = randi(numNodes);
    end

    
   
    X = X + (rand(1, numNodes) - 0.5) * nodeSpeed;
    Y = Y + (rand(1, numNodes) - 0.5) * nodeSpeed;
    X = max(min(X, areaSize), 0); % Alan dışına çıkmayı engelle
    Y = max(min(Y, areaSize), 0);
    
    
  
    for i = 1:numNodes
        if i == sourceNode
            plot(X(i), Y(i), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
            text(X(i)+10, Y(i)+10, 'Source');
        elseif i == destNode
            plot(X(i), Y(i), 'mo', 'MarkerSize', 12, 'MarkerFaceColor', 'm');
            text(X(i)+10, Y(i)+10, 'Dest');
        elseif i == wh1Node
            plot(X(i), Y(i), 'o', 'MarkerSize', 12, 'MarkerFaceColor', [1 0.5 0], 'MarkerEdgeColor', 'k');
            text(X(i)+10, Y(i)+10, 'Wormhole-1');
        elseif i == wh2Node
            plot(X(i), Y(i), 'o', 'MarkerSize', 12, 'MarkerFaceColor', [1 0.5 0], 'MarkerEdgeColor', 'k');
            text(X(i)+10, Y(i)+10, 'Wormhole-2');
        else
            plot(X(i), Y(i), 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b');
            text(X(i)+7, Y(i)+7, num2str(i));
        end
    end

    
    plot([X(wh1Node), X(wh2Node)], [Y(wh1Node), Y(wh2Node)], '-', 'Color', [1 0.5 0], 'LineWidth', 2.5);
    
   
    distances = zeros(numNodes, numNodes);
    for i = 1:numNodes
        for j = 1:numNodes
            distances(i,j) = sqrt((X(i)-X(j))^2 + (Y(i)-Y(j))^2);
            if distances(i,j) <= txRange && i ~= j
                plot([X(i), X(j)], [Y(i), Y(j)], 'k:', 'Color', [0.8 0.8 0.8]);
            end
        end
    end
    
   
    maxHops = 4;
    wormholeHops = countHopsToDest(distances, sourceNode, destNode, wh1Node, wh2Node, txRange, maxHops, true);
    honestHops   = countHopsToDest(distances, sourceNode, destNode, wh1Node, wh2Node, txRange, maxHops, false);

    destReached = ~isnan(wormholeHops);
    
    genuineAttack = destReached && (isnan(honestHops) || wormholeHops < honestHops);

   
    if genuineAttack
        if isnan(honestHops)
            hopMsg = sprintf('ROUTE HIJACKED: %d hop via tunnel (unreachable otherwise)', wormholeHops);
        else
            hopMsg = sprintf('ROUTE HIJACKED: %d hop via tunnel vs %d hop real path', wormholeHops, honestHops);
        end
        text(10, 20, hopMsg, 'Color', [1 0.5 0], 'FontWeight', 'bold');
        wormholeAttacks = wormholeAttacks + 1;
    elseif destReached
        text(10, 20, sprintf('PACKET DELIVERED (%d hop, tunnel gave no shortcut)', wormholeHops), 'Color', 'green', 'FontWeight', 'bold');
    else
        text(10, 20, 'Destination not reached within hop limit', 'Color', 'blue');
    end

   
    currentWormholeRate = (wormholeAttacks / totalAttempts) * 100;
    wormholeRateHistory = [wormholeRateHistory, currentWormholeRate];
    
  
    fprintf('Step: %d | Wormhole Attacks: %d | Wormhole Rate: %%%.2f\n', ...
            totalAttempts, wormholeAttacks, currentWormholeRate);
    drawnow; 
    pause(0.5); 
end

disp('--- Simulation Stopped ---');
disp('To plot a graph, type the following code into the Command Window:');
disp('plot(wormholeRateHistory, ''LineWidth'', 2); title(''Wormhole Success Rate Over Time''); xlabel(''Time Step''); ylabel(''Rate of Hijacked Routes (%)''); grid on;');


function hops = countHopsToDest(distances, source, dest, wh1, wh2, txRange, maxHops, useWormhole)
    currentNodes = find(distances(source, :) <= txRange & distances(source, :) > 0);
    visited = source;
    hops = NaN;

    for hop = 1:maxHops
        if useWormhole
            if ismember(wh1, currentNodes) && ~ismember(wh2, visited)
                currentNodes = [currentNodes, wh2];
            end
            if ismember(wh2, currentNodes) && ~ismember(wh1, visited)
                currentNodes = [currentNodes, wh1];
            end
        end

        if ismember(dest, currentNodes)
            hops = hop;
            return;
        end

        nextNodes = [];
        for n = currentNodes
            newNeighbors = find(distances(n, :) <= txRange & distances(n, :) > 0);
            nextNodes = [nextNodes, newNeighbors];
        end
        visited = [visited, currentNodes];
        currentNodes = setdiff(unique(nextNodes), visited);
    end
end