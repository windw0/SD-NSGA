% 判断是否生态占位。若发生占位，返回true、小群体的编号、不重复的最优个体；若不发生占位，则返回false、小群体的编号、[];
function [judge, num] = IncludeJudge(F_fm, F_fn, Dsm, Dsn)
    judge = false;  % 是否发生占位
    num = 0;        % 小群体的编号，若发生生态占位，则为要被取代的亚种群的编号
    F_fmNum = size(F_fm, 1);
    F_fnNum = size(F_fn, 1);
    judge1 = sum(ismember(F_fm, F_fn, 'row')) == F_fmNum;   % F_fm中的行都属于F_fn即为true
    judge2 = sum(ismember(F_fn, F_fm, 'row')) == F_fnNum;   % F_fn中的行都属于F_fm即为true
    if judge1 == 0 && judge2 == 0
        judge = false;
    else
        judge = true;
        if judge1 == 1 && judge2 == 0
            num = 1;
        elseif judge1 == 0 && judge2 == 1
            num = 2;
        else
            if Dsm >= Dsn
                num = 2;
            else 
                num = 1;
            end
        end
    end
end