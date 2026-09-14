clear; clc; close all;


numNodes = 20; areaSize = 500; txRange = 150;
nodeSpeed = 15; 
dropProbability = 0.45;


X = rand(1, numNodes) * areaSize;
Y = rand(1, numNodes) * areaSize;


totalAttempts = 0;
droppedPackets = 0;
successRateHistory = [];

grayholeNode = randi(numNodes);
fprintf('Gray Hole: Node %d\n', grayholeNode);

fig = figure('Name', 'AODV Grayhole Simulation', 'Position', [100, 100, 700, 700]);

disp('--- Simulation Started ---');
disp('The simulation will stop when you close the window.');

while ishandle(fig) 
    clf(fig); hold on; grid on; axis([0 areaSize 0 areaSize]);
    title('MANET Grayhole Attack');
    
    totalAttempts = totalAttempts + 1; % Her adımı bir RREQ denemesi say
    sourceNode = randi(numNodes);
    destNode = randi(numNodes);
    while isequal(sourceNode, destNode)
        destNode = randi(numNodes);
    end
  
    while isequal(grayholeNode, sourceNode) || isequal(grayholeNode, destNode)
        grayholeNode = randi(numNodes);
    end 

    
    
    X = X + (rand(1, numNodes) - 0.5) * nodeSpeed;
    Y = Y + (rand(1, numNodes) - 0.5) * nodeSpeed;
    X = max(min(X, areaSize), 0); 
    Y = max(min(Y, areaSize), 0);
    
   
    for i = 1:numNodes
        if i == sourceNode
            plot(X(i), Y(i), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
            text(X(i)+10, Y(i)+10, 'Source');
        elseif i == destNode
            plot(X(i), Y(i), 'mo', 'MarkerSize', 12, 'MarkerFaceColor', 'm');
            text(X(i)+10, Y(i)+10, 'Dest');
        elseif i == grayholeNode
            plot(X(i), Y(i), 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
            text(X(i)+10, Y(i)+10, 'Grayhole');
        else
            plot(X(i), Y(i), 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b');
            text(X(i)+7, Y(i)+7, num2str(i));
        end
    end
    
  
    distances = zeros(numNodes, numNodes);
    for i = 1:numNodes
        for j = 1:numNodes
            distances(i,j) = sqrt((X(i)-X(j))^2 + (Y(i)-Y(j))^2);
            if distances(i,j) <= txRange && i ~= j
                plot([X(i), X(j)], [Y(i), Y(j)], 'k:', 'Color', [0.8 0.8 0.8]);
            end
        end
    end
    
   
    grayholeReached = false;
    currentNodes = find(distances(sourceNode, :) <= txRange & distances(sourceNode, :) > 0);
    visited = sourceNode;
    
    for hop = 1:4 
        if ismember(grayholeNode, currentNodes)
            grayholeReached = true;
            break;
        end
        nextNodes = [];
        for n = currentNodes
            newNeighbors = find(distances(n, :) <= txRange & distances(n, :) > 0);
            nextNodes = [nextNodes, newNeighbors];
        end
        visited = [visited, currentNodes];
        currentNodes = setdiff(unique(nextNodes), visited);
    end
    
   
    if grayholeReached
       if rand() < dropProbability
           plot([X(sourceNode), X(grayholeNode)], [Y(sourceNode), Y(grayholeNode)], 'y-', 'LineWidth', 2.5);
           text(X(sourceNode), Y(sourceNode)-20, 'GRAY HOLE ATTACK', 'Color', '#D4AC0D', 'FontWeight', 'bold');
           droppedPackets = droppedPackets + 1;
       else
           plot([X(sourceNode), X(grayholeNode)], [Y(sourceNode), Y(grayholeNode)], 'g:', 'LineWidth', 1.5);
           text(X(sourceNode), Y(sourceNode)-20, 'PACKET DELIVERED', 'Color', 'green', 'FontWeight', 'bold');
       end
    else
        text(10, 20, 'Gray hole out of range, searching for RREQ....', 'Color', 'blue');
    end
    
    currentDropRate = (droppedPackets / totalAttempts) * 100;
    successRateHistory = [successRateHistory, currentDropRate];
    
   
    fprintf('Step: %d | Dropped Packet: %d | Drop Rate: %%%.2f\n', ...
            totalAttempts, droppedPackets, currentDropRate);
            
    drawnow;
    pause(0.5); 
end

disp('--- Simulation Stopped ---');
disp('To plot a graph, type the following code into the Command Window:');
disp('plot(successRateHistory, ''LineWidth'', 2); title(''Grayhole Success Rate Over Time''); xlabel(''Time Step''); ylabel(''Rate of Dropped Packets (%)''); grid on;');
