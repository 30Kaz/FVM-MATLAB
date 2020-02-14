    function facevalue=InterpolateValue(Mesh,Field,Type)
    %{
        global Domain;
        Mesh=Domain.Mesh;
        Field=Domain.Field;
        Fluid=Domain.Fluid;
        Solutionsystem=Domain.Solutionsystem;
    %}
    
    interiorface=Mesh.face.boundarynum+1:Mesh.face.number;
    
    switch Type
        case 'pressure'
            facevalue=Field.face.pressure;
%             facevalue=zeros(Mesh.face.number,1);
            %Boundary faces
            for i=1:Mesh.face.boundarynum
                switch Mesh.face.boundarycondition(i,1)
                    case 1      %Specific pressure
                        %do nothing
                    case {2,3}  %Specific velocity and no slip wall
                      facevalue(i,1)=Field.element.pressure(Mesh.face.owner(i,1))...
                                    +sum(Field.element.pressuregrad(Mesh.face.owner(i,1),:)...
                                   .*(Mesh.face.dCF(i).*Mesh.face.ecf(i,:)),2);  
                end
            end           
            %Interior faces
            facevalue(interiorface,1)=Mesh.face.gcf(interiorface,1).*Field.element.pressure(Mesh.face.owner(interiorface,1))...
                                     +Mesh.face.gcf(interiorface,2).*Field.element.pressure(Mesh.face.owner(interiorface,2)); %(9.5)
 
        case 'velocity'
            facevalue=Field.face.velocity;
%             facevalue=zeros(Mesh.face.number,3);
            %Boundary faces
            for i=1:Mesh.face.boundarynum
                switch Mesh.face.boundarycondition(i,1)
                    case {1,2,3}      %Specific pressure, specific velocity and no slip wall
                        %no updates
                    otherwise
                        disp('Undefined BC in InterpolateValue.m!!!!');
                end
            end
            %Interior faces
            facevalue(interiorface,:)=Mesh.face.gcf(interiorface,1).*Field.element.velocity(Mesh.face.owner(interiorface,1),:)...
                                     +Mesh.face.gcf(interiorface,2).*Field.element.velocity(Mesh.face.owner(interiorface,2),:);
            
        case 'pressure correction'
            facevalue=zeros(Mesh.face.number,1);
            %Boundary faces
            for i=1:Mesh.face.boundarynum
                switch Mesh.face.boundarycondition(i,1)
                    case 1      %Specific pressure
                        %do nothing
                    case {2,3}  %Specific velocity and no slip wall: no updates
                        facevalue(i,1)=Field.element.PCorrect(Mesh.face.owner(i,1))...
                                                 +sum(Field.element.PCorrectgrad(Mesh.face.owner(i,1),:)...
                                                 .*(Mesh.face.dCF(i).*Mesh.face.ecf(i,:)),2);
                end
            end
            %Interior faces
            facevalue(interiorface,1)=Mesh.face.gcf(interiorface,1).*Field.element.PCorrect(Mesh.face.owner(interiorface,1))...
                                     +Mesh.face.gcf(interiorface,2).*Field.element.PCorrect(Mesh.face.owner(interiorface,2));
    end
end

