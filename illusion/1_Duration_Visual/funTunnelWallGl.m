function funTunnelWallGl(i, texture, grid, ep)
    global GL;  
    epz = 0.2;
    % ep = 0.1;
    % Vector v maps indices to 3D positions of the corners of a face:
    v=[ grid.LeftBound grid.UpperBound grid.BackBound ; grid.RightBound grid.UpperBound grid.BackBound ; grid.RightBound grid.LowerBound grid.BackBound...
        ; grid.LeftBound grid.LowerBound grid.BackBound ; grid.LeftBound grid.UpperBound grid.FrontBound ; grid.RightBound grid.UpperBound grid.FrontBound...
        ; grid.RightBound grid.LowerBound grid.FrontBound ; grid.LeftBound grid.LowerBound grid.FrontBound ; ]';
    % Compute surface normal vector. Needed for proper lighting calculation:
    n= cross(v(:,i(2))-v(:,i(1)),v(:,i(3))-v(:,i(2)));
    
    % Bind (Select) texture 'tx' for drawing:
    glBindTexture(GL.TEXTURE_2D,texture);
    
    % Begin drawing of a new quad:
    glBegin(GL.QUADS);
    
    % Assign n as normal vector for this polygons surface normal:
    glNormal3f(n(1), n(2), n(3));
    
    % Define vertex 1 by assigning a texture coordinate and a 3D position:
    glTexCoord2f(ep, epz);
    glVertex3f(v(1,i(1)),v(2,i(1)),v(3,i(1)));
    % Define vertex 2 by assigning a texture coordinate and a 3D position:
    glTexCoord2f(1-ep, epz);
    glVertex3f(v(1,i(2)),v(2,i(2)),v(3,i(2)));
    % Define vertex 3 by assigning a texture coordinate and a 3D position:
    glTexCoord2f(1-ep, 1-epz);
    glVertex3f(v(1,i(3)),v(2,i(3)),v(3,i(3)));
    % Define vertex 4 by assigning a texture coordinate and a 3D position:
    glTexCoord2f(ep, 1-epz);
    glVertex3f(v(1,i(4)),v(2,i(4)),v(3,i(4)));
    % Done with this polygon:
    glEnd;
    
    % Return to main function:
end