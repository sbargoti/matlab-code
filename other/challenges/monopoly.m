%  code to solve monoply problem
clear all; close all;
tiles_str = {'GO','A1','CC1','A2','T1','R1','B1','CH1','B2','B3','JAIL',...
    'C1','U1','C2','C3','R2','D1','CC2','D2','D3','FP','E1','CH2','E2', ...
    'E3','R3','F1','F2','U2','F3','G2J','G1','G2','CC3','G3',...
    'R4','CH3','H1','T2','H2'};
tiles = 1:40;
% Community chest actions
cca = {@(x) 1, @(x) 11, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, ...
    @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x};
cha = {@(x) 1, @(x) 11, @(x) 12, @(x) 25, @(x) 40, @(x) 6, ...
    @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, ...
    @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, ...
    @(x) (x>=13)*(x<29)*29 + (x<13)*13 + (x>=29)*13, ...
    @(x) x-3, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x};
move_maker = @(x) (x<41)*x + (x>=41)*(x-40);
d1 = 6; d2 = 6;
max_games = 150;
max_throws = 1500;
% all_tile_counts = zeros(1,40);
all_tile_counts = randi(1,40,1)*0;

for j = 1:max_games
    
    tile_counts = zeros(40,1);
%     tile_counts(1) = 1;
    isdouble = 0;
    prev_tile = 1;
    current_tile = 1;
    cca_choice = 1;
    cha_choice = 1;

    cca_deck = my_rand_perm()';
    cha_deck = my_rand_perm()';
    
    for i = 1:max_throws
        move = [randi([1, d1], 1, 1), randi([1, d2], 1, 1)];
        isdouble = (move(1)==move(2))*(isdouble+1);

        if isdouble == 3 % third double in a row?
            current_tile = 11; % Move to jail
        else
            current_tile = move_maker(current_tile+sum(move));
            if sum(current_tile == [3, 18, 34]) % are we on a community chest?
%                 fprintf('Stopped at community chest, drew %.0f\n',cca_deck(1))
%                 fprintf('Changed postion from %s',tiles_str{current_tile})
%                 current_tile = cca{cca_deck(1)}(current_tile);
                    current_tile = cca{cca_deck(cca_choice)}(current_tile);
                    cca_choice = (cca_choice<16)*(cca_choice+1) + (cca_choice>=16)*1;
%                 fprintf(' to %s\n', tiles_str{current_tile})
%                 pause
%                 cca_deck = circshift(cca_deck,-1);
            elseif sum(current_tile == [8, 23, 37]) % Chance
%                 fprintf('Stopped at Chance, drew %.0f\n',cha_deck(1))
%                 fprintf('Changed postion from %s',tiles_str{current_tile})
%                 current_tile = cha{cha_deck(1)}(current_tile);
                current_tile = cha{cha_deck(cha_choice)}(current_tile);
                cha_choice = (cha_choice<16)*(cha_choice+1) + (cha_choice>=16)*1;
%                 fprintf(' to %s\n', tiles_str{current_tile})
%                 pause
%                 cha_deck = circshift(cha_deck,-1);
            elseif current_tile == 31 % Go to Jail
                current_tile = 11;
            end
        end
        % current_tile
%         if current_tile == prev_tile
%             % Do Nothing
%         else
            tile_counts(current_tile) = tile_counts(current_tile) + 1;
%             prev_tile = current_tile;
%         end
    end
    if ~mod(j, 50)
        fprintf('Sampled %.0f of %.0f games\n',j, max_games)
    end
    all_tile_counts = all_tile_counts + tile_counts;
end

[tile_probs, idx_order] = sort(all_tile_counts/sum(all_tile_counts),'descend');
fprintf('1st most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(1)}, tile_probs(1)*100)
fprintf('2nd most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(2)}, tile_probs(2)*100)
fprintf('3rd most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(3)}, tile_probs(3)*100)