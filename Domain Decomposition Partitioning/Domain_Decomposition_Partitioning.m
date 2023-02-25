%---------------- MAIN PROGRAM ----------------%
clear; clc;

% Step 1: Input Data
num_nodes = 15;
num_elem = 24;
num_sub = 2;
file = fopen('partitioning_data1.txt','r');
[x,y,z,nodei,nodej,nodek] = input_data(num_nodes,num_elem,file);

% Step 2: Calculate Rank
[ranks] = count_rank(num_nodes,num_elem,nodei,nodej,nodek);

% Step 3 & 4: Finding the Start Nodes
[starting_nodes] = find_start_nodes(x,y,z,ranks,num_sub,num_nodes);

% Step 5: Finding the Nodes in the Sub-domains
[subdomain_nodes] = find_subdomain_nodes(num_elem,starting_nodes,num_sub,num_nodes,nodei,nodej,nodek,ranks,x,y,z);

% Step 6: 

%---------------- FUNCTIONS ----------------%
function [x,y,z,nodei,nodej,nodek] = input_data(num_nodes,num_elem,file)
    for node = 1:1:num_nodes
        node_number = fscanf(file,'%d',1);
        x(node_number) = fscanf(file,'%g',1);
        y(node_number) = fscanf(file,'%g',1);
        z(node_number) = fscanf(file,'%g',1);
    end
    for elem = 1:1:num_elem
        ele_number = fscanf(file,'%d',1);
        nodei(ele_number) = fscanf(file,'%g',1);
        nodej(ele_number) = fscanf(file,'%g',1);
        nodek(ele_number) = fscanf(file,'%g',1);
    end
    disp("X:")
    disp(x)
    disp("Y:")
    disp(y)
    disp("Z:")
    disp(z)
    disp("Node I:")
    disp(nodei)
    disp("Node J:")
    disp(nodej)
    disp("Node K:")
    disp(nodek)
end

function [ranks] = count_rank(num_nodes,num_elem,nodei,nodej,nodek)
    for i = 1:1:num_nodes
        count = 0;
        for j = 1:1:num_elem
            if nodei(j) == i || nodej(j) == i || nodek(j) == i
                count = count + 1;
            end
        end
        ranks(i) = count;
    end
    disp("Ranks: ")
    disp(ranks)
end

function [starting_nodes] = find_start_nodes(x,y,z,ranks,num_sub,num_nodes)
    starting_nodes = zeros(1,num_sub);
    for s = 1:1:num_sub
        count = 0;
        for i = 1:1:num_nodes
            lowest_rank = min(ranks);
            if lowest_rank == ranks(i)
                if any(starting_nodes == i) ~= true
                    count = count + 1;
                    start_nodes(count) = i;
                end
            end
        end
        if count == 1
            starting_nodes(s) = start_nodes(count);
        elseif s == 1
            starting_nodes(s) = min(start_nodes);
        elseif s > 1
            distance = zeros(1,count);
            for i = 1:1:(s-1)
                for j = 1:1:count
                    distance(j) = (distance(j) + ((sqrt((x(starting_nodes(i))-x(start_nodes(j)))^2)+(y(starting_nodes(i))-y(start_nodes(j)))^2)));
                end
            end
            if numel(find(distance == max(distance))) == 1
                for i = 1:1:count
                    if max(distance) == distance(i)
                        starting_nodes(s) = start_nodes(i);
                    end
                end
            else
                repeats = 0;
                holder = 1/0;
                next_step = 1;
                max_distance = 0;
                min_distance = 1/0;
                for i = 1:1:count
                    if max(distance) == distance(i)
                        repeats = repeats + 1;
                        node(repeats) = start_nodes(i);
                    end
                end
                for j = 1:1:repeats
                    for i = 1:1:(s-1)
                        if max_distance < ((sqrt((x(starting_nodes(i))-x(node(j)))^2)+(y(starting_nodes(i))-y(node(j)))^2))
                            max_distance = ((sqrt((x(starting_nodes(i))-x(node(j)))^2)+(y(starting_nodes(i))-y(node(j)))^2));
                        end
                        if min_distance > ((sqrt((x(starting_nodes(i))-x(node(j)))^2)+(y(starting_nodes(i))-y(node(j)))^2))
                            min_distance = ((sqrt((x(starting_nodes(i))-x(node(j)))^2)+(y(starting_nodes(i))-y(node(j)))^2));
                        end
                    end
                    if holder > abs(max_distance-min_distance)
                        holder = abs(max_distance-min_distance);
                        starting_nodes(s) = node(j);
                        if holder == abs(max_distance-min_distance)
                            duplicates(next_step) = node(j);
                            next_step = next_step + 1;
                        end
                    end
                end
                starting_nodes(s) = min(duplicates);
            end
        end
    end
    disp("Starting Nodes:")
    disp(starting_nodes)
end

function [subdomain_nodes] = find_subdomain_nodes(num_elem,starting_nodes,num_sub,num_nodes,nodei,nodej,nodek,ranks,x,y,z)
    
    % Intializing the Start Nodes into the subdomains
    for i = 1:1:num_sub
        subdomain_nodes(i,1) = starting_nodes(i);
    end
    holder = 1;
    holder1 = 2;
    continuation = 1;
    remaining_nodes = num_nodes - num_sub;
    
    while continuation == 1
        for s = 1:1:num_sub
            if remaining_nodes > 0
                count = 0;
                possible_nodes = zeros(1,1);
                first_possible_elements = zeros(1,1);
                current_subdomain_nodes = zeros(1,1);
                
                % Initializing Nodes in the current sub domain
                for i = 1:1:holder
                    current_subdomain_nodes(i) = subdomain_nodes(s,i);
                end

                % Checking to see if any element is present given nodes
                for i = 1:1:num_elem
                    if any(current_subdomain_nodes == nodei(i)) == true||any(current_subdomain_nodes == nodej(i)) == true||any(current_subdomain_nodes == nodek(i)) == true
                        if (any(current_subdomain_nodes == nodei(i)) == true && any(current_subdomain_nodes == nodej(i)) == true) == false
                            placeholder = 1;
                            count = count + 1;
                            if any(subdomain_nodes == nodei(i)) ~= true
                                if nodei(i) ~= 0
                                    possible_nodes(placeholder,count) = nodei(i);
                                    first_possible_elements(count) = i;
                                    placeholder = placeholder + 1;
                                end
                            end
                            if any(subdomain_nodes == nodej(i)) ~= true
                                if nodej(i) ~= 0
                                    possible_nodes(placeholder,count) = nodej(i);
                                    first_possible_elements(count) = i;
                                    placeholder = placeholder + 1;
                                end
                            end
                            if any(subdomain_nodes == nodek(i)) ~= true
                                if nodek(i) ~= 0
                                    possible_nodes(placeholder,count) = nodek(i);
                                    first_possible_elements(count) = i;
                                    placeholder = placeholder + 1;
                                end
                            end
                        end
                    end
                end

                % Checking for the lowest rank
                average = zeros(1,count);
                sizes = 0;
                repeat = 0;
                second_possible_elements = zeros(1,1);
                disp(possible_nodes)
                disp(first_possible_elements)
                if any(possible_nodes == 0) ~= true
                    if length(possible_nodes) == 1
                        subdomain_nodes(s,holder1) = possible_nodes(1,1);
                        remaining_nodes = remaining_nodes - 1;
                    else
                        [m,n] = size(possible_nodes);
                        for i = 1:1:n
                            sizes = 0;
                            repeat = repeat + 1;
                            for j = 1:1:m
                                sizes = sizes + 1;
                                average(repeat) = average(repeat) + ranks(possible_nodes(j,i));
                            end
                        end
                        % Checking for lowest distance
                        if repeat == 1
                            subdomain_nodes(s,holder1) = average(1,1);
                            remaining_nodes = remaining_nodes - 1;
                        else
                            distance_nodes = zeros(1,1);
                            placeholder = 0;
                            for i = 1:1:repeat
                                if average(i) == min(average)
                                    placeholder = placeholder + 1;
                                    distance_nodes(placeholder) = possible_nodes(i);
                                    second_possible_elements(placeholder) = first_possible_elements(i);
                                end
                            end
                            if placeholder == 1
                                subdomain_nodes(s,holder1) = distance_nodes(placeholder);
                                remaining_nodes = remaining_nodes - 1;
                            else
                                placeholder1 = 0;
                                distance = zeros(1,1);
                                for i = 1:1:placeholder
                                    placeholder1 = placeholder1 + 1;
                                    distance(placeholder1) = sqrt((x(nodei(second_possible_elements(i))) - x(nodej(second_possible_elements(i))))^2 + (y(nodei(second_possible_elements(i))) - y(nodej(second_possible_elements(i))))^2);
                                end
                                continuing = 0;
                                third_possible_elements = zeros(1,1);
                                third_possible_nodes = zeros(1,1);
                                for i = 1:1:placeholder
                                    if distance(i) == min(distance)
                                        continuing = continuing + 1;
                                        third_possible_nodes(continuing) = distance_nodes(i);
                                        third_possible_elements(continuing) = second_possible_elements(i);
                                    end
                                end
                                if placeholder == continuing
                                    for i = 1:1:continuing
                                        if min(third_possible_elements) == third_possible_elements(i)
                                            subdomain_nodes(s,holder1) = third_possible_nodes(i);
                                            remaining_nodes = remaining_nodes - 1;
                                        end
                                    end
                                else
                                    subdomain_nodes(s,holder1) = third_possible_nodes(1);
                                    remaining_nodes = remaining_nodes - 1;
                                end
                            end
                        end
                    end
                end
                    
            else
                continuation = 0;
            end
            disp(subdomain_nodes)
        end
        holder = holder + 1;
        holder1 = holder1 + 1;
    end
    for i = 1:1:num_sub
        disp("Subdomain " + i + ":")
        disp(subdomain_nodes(i,:))
    end
end

