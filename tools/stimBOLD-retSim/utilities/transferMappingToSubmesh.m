function [msh] = transferMappingToSubmesh(msh)

counter = 1;
areaCodes = {'v1','v2','v3'};
for vis = 1:length(areaCodes);
    va = areaCodes{vis};
    eval(['coords = msh.submesh.visualAreas.' va ';']);
    [nold,coords] = find(msh.submesh.fullToSub(coords,:));
    eval(['msh.submesh.visualAreas.' va ' = coords;']);
    
    eval(['msh.submesh.ecMap.' va ' = msh.submesh.ecMap.' va '(nold);']);
    eval(['msh.submesh.polMap.' va ' = msh.submesh.polMap.' va '(nold);']);
    visTagInArea = counter*ones(size(coords));
    eval(['msh.submesh.visTag.' va ' = visTagInArea;']);
    counter = counter + 1;
end

end
