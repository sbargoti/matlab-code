function a = andrew_monopoly(d1, d2)
tiles = [1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 2/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 0 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40 1/40];
move = [1,0.0000000000000000000000000001:0.0000000000000000000000000001:0.0000000000000000000000000001*(d1+d2-1)];
CHCC = [1/16 0 0 0 1/16 1/16 0 -10/16 0 0 1/16 1/16 1/16 0 0 2/16 0 0 0 0 0 0 0 0 1/16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/16; 1/16 0 0 0 0 1/16 0 0 0 0 1/16 1/16 0 0 0 0 0 0 0 1/16 0 0 -10/16 0 1/16 2/16 0 0 1/16 0 0 0 0 0 0 0 0 0 0 1/16; 1/16+1/16^2 0 0 0 0 3/16 0 0 0 0 1/16+1/16^2 1/16 1/16 0 0 0 0 0 0 0 0 0 0 0 1/16 0 0 0 0 0 0 0 0 14/(16^2) 0 0 -10/16 0 0 1/16;1/16 0 -2/16 0 0 0 0 0 0 0 1/16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 1/16 0 0 0 0 0 0 0 0 0 1/16 0 0 0 0 0 0 -2/16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 1/16 0 0 0 0 0 0 0 0 0 1/16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -2/16 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 (1-((d1+d2)/2 - abs(d1-d2)/2)/(d1*d2)) * (((d1+d2)/2 - abs(d1-d2)/2)/(d1*d2))^3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % Transition probabilities for chance, community chest, go to jail, roll doubles (1 non-double followed by 3 doubles)
for i = 1:d1 % Calculate the probability of each movement (subtracting the rate for 3 doubles in a row following a non-double)
    move(i+1:i+d2) = move(i+1:i+d2) + 1/(d1*d2) - (1 - abs(i-[1:d2])./max(1,abs(i-[1:d2])))*CHCC(8,11)/((d1+d2)/2 - abs(d1-d2)/2);
end
while move(1) > 0.00005
    tiles_old = tiles;
    tiles = 0 * tiles;
    for i = 1:40
        for j = 2:(d1+d2)
            tiles(i+j - floor((i+j-1)/40)*40) = tiles(i+j - floor((i+j-1)/40)*40) + tiles_old(i) * move(j);
        end
    end
    tiles = tiles + CHCC(1,:)*tiles(8) + CHCC(2,:)*tiles(23) + CHCC(3,:)*tiles(37) + CHCC(4,:)*tiles(3) + CHCC(5,:)*tiles(18) + CHCC(6,:)*tiles(34) + CHCC(7,:)*tiles(31) + CHCC(8,:);
    move(1) = max(abs(tiles_old - tiles));
end
for i = 1:3 % Get the 3 maximum probability tiles
    a(i) = sum((tiles==max(tiles)).*(1:40)) - 1;
    tiles(a(i) + 1) = 0;
end