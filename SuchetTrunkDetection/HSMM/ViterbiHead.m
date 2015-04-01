function path = ViterbiHead(PAI, A, B, C)

if isa(A,'function_handle')
    B(B == 0) = NaN;
    C(C == 0) = NaN;
    
    PAI_log = log(PAI);
    B_log = log(B);
    C_log = log(C);
    
    path = Viterbi(PAI_log, A, B_log, C_log);
else
    A(A == 0) = NaN;
    B(B == 0) = NaN;
    C(C == 0) = NaN;
    
    PAI_log = log(PAI);
    A_log = log(A);
    B_log = log(B);
    C_log = log(C);
    
    path = Viterbi(PAI_log, A_log, B_log, C_log);
end

end