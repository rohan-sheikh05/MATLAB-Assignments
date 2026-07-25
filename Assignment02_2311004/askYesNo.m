
function tf=askYesNo(q)
while true
 a=input([q ' (1=Yes,0=No): ']);
 if ismember(a,[0 1]); tf=logical(a); return; end
 disp('Invalid input. Enter 1 or 0.');
end
end
