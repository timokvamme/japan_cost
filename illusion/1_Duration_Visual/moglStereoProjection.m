function moglStereoProjection(left, right, bottom, top, near, far, zero_plane, dist, eye)
    % moglStereoProjection(left, top, right, bottom, near, far, zero_plane, dist, eye)
    %
    % Set up the stereo projection matrices for binocular stereo projection.
    % Taken verbatim from Quoc Vuong's class on Computer Graphics for Vision Research,
    % http://www.kyb.mpg.de/bu/people/qvuong/CGV05.html
    %
    % Requires: glMatrixMode(GL.PROJECTION) being set before call. Backup your
    % matrices if you need'em later!
    
    dx = right - left;
    dy = top - bottom;
    
    xmid = (right + left) / 2.0;
    ymid = (top + bottom) / 2.0;
    
    clip_near = dist + zero_plane - near;
    clip_far  = dist + zero_plane - far;
    
    n_over_d = clip_near / dist;
    
    topw = n_over_d * dy / 2.0;
    bottomw = -topw;
    rightw = n_over_d * (dx / 2.0 - eye);
    leftw  = n_over_d *(-dx / 2.0 - eye);
    
    %// Create a fustrum, and shift it off axis
    %// glTranslate() applies to PROJECTION matrix
    glLoadIdentity();
    glFrustum(leftw,  rightw,  bottomw,  topw, clip_near,  clip_far);
    glTranslatef(-xmid - eye,  -ymid,  -zero_plane -dist);
end