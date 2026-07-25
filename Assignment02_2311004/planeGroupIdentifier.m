%we know in 2d we have 17 plane groups.
%here in this code it takes input by using two functions named askYesNo and
%askRotation. and in the main file it asks sevelral question based on the
%first response which is rotation and for each rotation value( 1 to 6) we
%have different sets of question to separate them effectively. and finally
%we printed our answer what we stored in var named group. 
function planeGroupIdentifier

rotation = askRotation();
group='';

switch rotation
    case 6
        if askYesNo('Has reflection symmetry?')
            group='p6mm';
        else
            group='p6';
        end
    case 4
        if ~askYesNo('Has reflection symmetry?')
            group='p4';
        else
            if askYesNo('Has mirrors at 45 degrees?')
                group='p4m';
            else
                group='p4g';
            end
        end
    case 3
        if ~askYesNo('Has reflection symmetry?')
            group='p3';
        else
            if askYesNo('Is rotation centre on mirror?')
                group='p3m1';
            else
                group='p31m';
            end
        end
    case 2
        if askYesNo('Has reflection symmetry?')
            if askYesNo('Has perpendicular mirrors?')
                if askYesNo('Is rotation centre off mirrors?')
                    group='cmm';
                else
                    group='pmm';
                end
            else
                group='pmg';
            end
        else
            if askYesNo('Has glide reflection?')
                group='pgg';
            else
                group='p2';
            end
        end
    case 1
        if askYesNo('Has reflection symmetry?')
            if askYesNo('Has glide axis on mirrors?')
                group='cm';
            else
                group='pm';
            end
        else
            if askYesNo('Has glide reflection?')
                group='pg';
            else
                group='p1';
            end
        end
end

fprintf('\n Identified Plane Group: %s \m',group);
end
