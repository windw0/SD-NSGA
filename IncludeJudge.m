% �ж��Ƿ���̬ռλ��������ռλ������true��СȺ��ı�š����ظ������Ÿ��壻��������ռλ���򷵻�false��СȺ��ı�š�[];
function [judge, num] = IncludeJudge(F_fm, F_fn, Dsm, Dsn)
    judge = false;  % �Ƿ���ռλ
    num = 0;        % СȺ��ı�ţ���������̬ռλ����ΪҪ��ȡ��������Ⱥ�ı��
    F_fmNum = size(F_fm, 1);
    F_fnNum = size(F_fn, 1);
    judge1 = sum(ismember(F_fm, F_fn, 'row')) == F_fmNum;   % F_fm�е��ж�����F_fn��Ϊtrue
    judge2 = sum(ismember(F_fn, F_fm, 'row')) == F_fnNum;   % F_fn�е��ж�����F_fm��Ϊtrue
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