function result = suchet_code_1(d1, d2)
cca = {@(x) 1, @(x) 11, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x}; % functions for community chest
cha = {@(x) 1, @(x) 11, @(x) 12, @(x) 25, @(x) 40, @(x) 6, @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, @(x) (x>=13)*(x<29)*29 + (x<13)*13 + (x>=29)*13, @(x) x-3, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x}; % functions for chance
move_maker = [1,1;2,2;3,3;4,4;5,5;6,6;7,7;8,8;9,9;10,10;11,11;12,12;13,13;14,14;15,15;16,16;17,17;18,18;19,19;20,20;21,21;22,22;23,23;24,24;25,25;26,26;27,27;28,28;29,29;30,30;31,31;32,32;33,33;34,34;35,35;36,36;37,37;38,38;39,39;40,40;41,1;42,2;43,3;44,4;45,5;46,6;47,7;48,8;49,9;50,10;51,11;52,12;53,13;54,14;55,15;56,16;57,17;58,18;59,19;60,20;61,21;62,22;63,23;64,24;65,25;66,26;67,27;68,28;69,29;70,30;71,31;72,32;73,33;74,34;75,35;76,36;77,37;78,38;79,39;80,40]; % cycle board count once past 40
max_throws = 200000; % Hacky.. need to fix this
movesum = randi([1, d1], max_throws, 1)+randi([1, d2], max_throws, 1);
doubleprob = randi([1, 216], max_throws, 1);
tile_counts = zeros(40,1);
current_tile = 1;
cca_choice = 1;
cha_choice = 1;
cca_deck = 1:16;
cha_deck = 1:16;
for i = 1:max_throws
    if doubleprob(i) == 3 % third double in a row?
        current_tile = 11; % Move to jail
    else
        current_tile = move_maker(current_tile+movesum(i), 2);
        if current_tile == 37 % Chance - perhaps go back to cc3
            current_tile = cha{cha_deck(cha_choice)}(current_tile);
            cha_choice = (cha_choice<16)*(cha_choice+1) + (cha_choice>=16)*1;
        end
        if current_tile == 3 || current_tile == 18 || current_tile == 34 % are we on a community chest?
            current_tile = cca{cca_deck(cca_choice)}(current_tile);
            cca_choice = (cca_choice<16)*(cca_choice+1) + (cca_choice>=16)*1;
        elseif current_tile == 8 || current_tile == 23 % Chance
            current_tile = cha{cha_deck(cha_choice)}(current_tile);
            cha_choice = (cha_choice<16)*(cha_choice+1) + (cha_choice>=16)*1;
        elseif current_tile == 31 % Go to Jail
            current_tile = 11;
        end
    end
    tile_counts(current_tile) = tile_counts(current_tile) + 1;
end
for i = 1:3
    [~, tile] = max(tile_counts);
    result(i) = tile-1;
    tile_counts(tile)=0;
end