
function r=askRotation()
while true
 r=input(['Rotation order (1,2,3,4,6): ']);
 if ismember(r,[1 2 3 4 6]); return; end
 disp('Invalid rotation order.');
end
end
