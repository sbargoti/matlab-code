function output = monopoly(dice1, dice2)

tic
output = [];
%Card Shuffling
%Community Chest
comm_chest = zeros(1,16);
GO = ceil(16*rand);
comm_chest(GO) = 1;
JAIL = ceil(15*rand);
empty = find(comm_chest == 0);
comm_chest(empty(JAIL)) = 2;
%Chance
chance = zeros(1,16);
GO = ceil(16*rand);
JAIL = ceil(15*rand);
C1 = ceil(14*rand);
E3 = ceil(13*rand);
H2 = ceil(12*rand);
R1 = ceil(11*rand);
Ut = ceil(10*rand);
BACK3 = ceil(9*rand);
RR = ceil(8*rand);
RR2 = ceil(7*rand);
cell_form = [GO, JAIL, C1, E3, H2, R1, Ut, BACK3, RR, RR2];%Chance Cards
for i = 1:10
    empty = find(chance == 0);
    comm_chest(empty(cell_form(i))) = i;
end
amend = find(chance == 10);
chance(amend) = 9;

tile_hist = zeros(1,40); %Squares on the board
current_tile = 1; %start location
counter = 0;
prev_roll = 0;
for dice_roll = 1:100000 %#Dice Rolls
    
    dice1roll = ceil(rand*dice1);
    dice2roll = ceil(rand*dice2);
    dice_sum = dice1roll + dice2roll;
    
    current_tile = mod(current_tile + dice_sum,40);
    if current_tile == 0
        current_tile = 40;
    end
    
    %If landed on a community chest tile
    if ((current_tile == 3) || (current_tile == 18) || (current_tile == 34))
        card = comm_chest(1);
        comm_chest = circshift(comm_chest',1)';
        if card == 1
            current_tile = 1; %Go
        elseif card == 2
            current_tile = 11; %Jail
        end
        %If landed on a chance tile
    elseif ((current_tile == 8) || (current_tile == 23) || (current_tile == 37))
        card = chance(1);
        chance = circshift(comm_chest',1)';
        if card == 1
            current_tile = 1; %Go
        elseif card == 2
            current_tile = 11; %Jail
        elseif card == 3
            current_tile = 12; %C1
        elseif card == 4
            current_tile = 25; %E3
        elseif card == 5
            current_tile = 40; %H2
        elseif card == 6
            current_tile = 6; %R1
        elseif card == 7 %Utility
            if current_tile == 23 %Next Utility
                current_tile = 29;
            else
                current_tile = 13;
            end
        elseif card == 8 %Go back 3 spaces
            current_tile = current_tile - 3;
        elseif card == 9 %Next Station, depends on current location on board
            if current_tile == 8
                current_tile = 16;
            elseif current_tile == 23
                current_tile = 26;
            else
                current_tile = 6;
            end
        end
    end
    
    if ((dice1 == dice2) && (prev_roll == dice_sum))
        counter = counter + 1;
    elseif (dice1 == dice2)
        counter = 1;
    else
        counter = 0;
    end
    if counter == 3
        current_tile = 11;
        counter = 0;
    end
    
    if current_tile == 31%Land on go to jail
        current_tile = 11;
    end
    prev_roll = dice_sum;
    tile_hist(current_tile) = tile_hist(current_tile) + 1;
end
%Generate answer
for anscount = 1:3
    [~,pp] = max(tile_hist);
    output = [output,pp];
    tile_hist(pp) = 0;
end
toc
end
%Post game analysis
% bar(tile_hist);
% [max_value1 location1] = max(tile_hist);
% tile_hist(location1) = 0;
% [max_value2 location2] = max(tile_hist);
% tile_hist(location2) = 0;
% [max_value3 location3] = max(tile_hist);
% tile_hist(location3) = 0;
