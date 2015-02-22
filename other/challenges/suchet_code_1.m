function probs = suchet_code_1(d1, d2, thresh)
    cca = {@(x) 1, @(x) 11, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x}; % functions for community chest
    cha = {@(x) 1, @(x) 11, @(x) 12, @(x) 25, @(x) 40, @(x) 6, @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, @(x) (x>=6)*(x<16)*16 + (x>=16)*(x<26)*26 + (x<6)*6 + (x>=26)*6, @(x) (x>=13)*(x<29)*29 + (x<13)*13 + (x>=29)*13, @(x) x-3, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x, @(x) x}; % functions for chance
    move_maker = @(x) (x<41)*x + (x>=41)*(x-40); % cycle board count once past 40
    max_games = round(1/thresh / 7); % Hacky.. need to fix this
    max_throws = round(1/thresh * 2); % Hacky.. need to fix this
    all_tile_counts = randi(1,40,1)*0; % initialise tile counts from all games
    for j = 1:max_games % Go through each game
        tile_counts = randi(1,40,1)*0; % initialise tile count for current game
        isdouble = 0; % initialise double throw count
        current_tile = 1; % starting tile
        cca_choice = 1; % community card count
        cha_choice = 1; % chance card count
        cca_deck = build_rand_perm()'; % Shuffle cards
        cha_deck = build_rand_perm()'; % Shuffle cards
        for i = 1:max_throws
            move = [randi([1, d1], 1, 1), randi([1, d2], 1, 1)]; % Roll dice
            isdouble = (move(1)==move(2))*(isdouble+1);
            if isdouble == 3 % third double in a row?
                current_tile = 11; % Move to jail
            else
                current_tile = move_maker(current_tile+sum(move));
                if sum(current_tile == [3, 18, 34]) % are we on a community chest?
                        current_tile = cca{cca_deck(cca_choice)}(current_tile);
                        cca_choice = (cca_choice<16)*(cca_choice+1) + (cca_choice>=16)*1;
                elseif sum(current_tile == [8, 23, 37]) % Chance
                    current_tile = cha{cha_deck(cha_choice)}(current_tile);
                    cha_choice = (cha_choice<16)*(cha_choice+1) + (cha_choice>=16)*1;
                elseif current_tile == 31 % Go to Jail
                    current_tile = 11;
                end
            end
            tile_counts(current_tile) = tile_counts(current_tile) + 1;
        end
        all_tile_counts = all_tile_counts + tile_counts;
    end
    probs = all_tile_counts/sum(all_tile_counts);

function vec = build_rand_perm()
    vec = randi([1 16],1,1);
    while size(vec)<16
        new_num = randi([1 16],1,1);
        if ~sum(vec == new_num)
            vec(end+1) = new_num;
        end
    end