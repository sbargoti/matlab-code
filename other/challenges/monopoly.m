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
% move_maker = @(x) (x<41)*x + (x>=41)*(x-40);
move_maker = [1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8;9,9;10,10;11,11;12,12;13,13;14,14;15,15;16,16;17,17;18,18;19,19;20,20;21,21;22,22;23,23;24,24;25,25;26,26;27,27;28,28;29,29;30,30;31,31;32,32;33,33;34,34;35,35;36,36;37,37;38,38;39,39;40,40;41,1;42,2;43,3;44,4;45,5;46,6;47,7;48,8;49,9;50,10;51,11;52,12;53,13;54,14;55,15;56,16;57,17;58,18;59,19;60,20;61,21;62,22;63,23;64,24;65,25;66,26;67,27;68,28;69,29;70,30;71,31;72,32;73,33;74,34;75,35;76,36;77,37;78,38;79,39;80,40];
d1 = 10; d2 = 15;
max_games = 150;
max_throws = 200000;
% all_tile_counts = zeros(1,40);
% all_tile_counts = randi(1,40,1)*0;
cca_deck = 1:16;
cha_deck = 1:16;
move = [randi([1, d1], max_throws, 1), randi([1, d2], max_throws, 1), randi([1, d1], max_throws, 1)+randi([1, d1], max_throws, 1)]; 
movesum = randi([1, d1], max_throws, 1)+randi([1, d1], max_throws, 1);
doubleprob = randi([1, 216], max_throws, 1);

% for j = 1:max_games
    
    tile_counts = zeros(40,1);
%     tile_counts(1) = 1;
    isdouble = 0;
    % prev_tile = 1;
    current_tile = 1;
    cca_choice = 1;
    cha_choice = 1;

    % cca_deck = my_rand_perm()';
    % cha_deck = my_rand_perm()';
    
    for i = 1:max_throws
        % move = [randi([1, d1], 1, 1), randi([1, d2], 1, 1)];
%         isdouble = (move(i, 1)==move(i, 2))*(isdouble+1);

        if doubleprob(i) == 3 % third double in a row?
            current_tile = 11; % Move to jail
        else
%             current_tile = move_maker(current_tile+movesum(i));
            current_tile = move_maker(current_tile+movesum(i), 2);
            if current_tile == 37 % Chance - perhaps go back to cc3
                current_tile = cha{cha_deck(cha_choice)}(current_tile);
                cha_choice = (cha_choice<16)*(cha_choice+1) + (cha_choice>=16)*1;
            end
            
            if current_tile == 3 || current_tile == 18 || current_tile == 34 % are we on a community chest?
%                 fprintf('Stopped at community chest, drew %.0f\n',cca_deck(1))
%                 fprintf('Changed postion from %s',tiles_str{current_tile})
%                 current_tile = cca{cca_deck(1)}(current_tile);
                    current_tile = cca{cca_deck(cca_choice)}(current_tile);
                    cca_choice = (cca_choice<16)*(cca_choice+1) + (cca_choice>=16)*1;
%                 fprintf(' to %s\n', tiles_str{current_tile})
%                 pause
%                 cca_deck = circshift(cca_deck,-1);
            elseif current_tile == 8 || current_tile == 23 % Chance
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
    % end
    if ~mod(i, 500)
        fprintf('Sampled %.0f of %.0f games\n',i, max_throws)
    end
    % all_tile_counts = all_tile_counts + tile_counts;
end
% end

% [tile_probs, idx_order] = sort(all_tile_counts/sum(all_tile_counts),'descend');
[tile_probs, idx_order] = sort(tile_counts/sum(tile_counts),'descend');
fprintf('1st most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(1)}, tile_probs(1)*100)
fprintf('2nd most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(2)}, tile_probs(2)*100)
fprintf('3rd most probable card: %s, with probability %2.2f%%\n', tiles_str{idx_order(3)}, tile_probs(3)*100)
for i = 1:3
    [~, tile] = max(tile_counts);
    out(i) = tile-1;
    tile_counts(tile)=0;
end
out