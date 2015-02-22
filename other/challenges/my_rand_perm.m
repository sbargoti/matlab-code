function vec = my_rand_perm()
vec = randi([1 16],1,1);
while size(vec)<16
    new_num = randi([1 16],1,1);
    if ~sum(vec == new_num)
        vec(end+1) = new_num;
    end
end
