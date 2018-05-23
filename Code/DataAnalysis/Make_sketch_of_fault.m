%% Make sketch
tic
clear
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_distance')


%d = abs(cross(Q2-Q1,P-Q1))/abs(Q2-Q1);
%Specifications
x=30;
y=40;
z=20;
d=20;

n=4;

color=jet(400);
%color=flipud(color);

%r=[1/3, 1/5];

rc=[ x-10/2, 13,10
     x-10/2, 27,10
     x-16/2, 27,16
     x-16/2, 13,16];
 %%%%%%%%%%%%%%%%%%%%%%%

 a=rc(4,3);
 b=a*(x-d)/z;
 c=sqrt(a^2+b^2);
 %d2=c*z/(x-d)
 %s=sqrt(d2^2+c^2)
 s=a*z/(x-d);

 a2=rc(1,3);
 b2=a2*(x-d)/z;
 s2=a2*z/(x-d);

alpha=asind(b/c);
betha=90-alpha;
h=a-sind(alpha)*rc(4,1)/sind(betha);

figure
view(3)
%xp1=[0,x-s-b,rc(1,1),d,0,0];
%zp1=[0,0,rc(1,3),z,z,0];

xp1=[0,rc(4,1),d,0,0];
zp1=[h,rc(4,3),z,z,h];

xp2=[x-s-b,x-s2-b2 ,rc(1,1),rc(4,1), x-s-b];
zp2=[0,0,rc(1,3),rc(4,3),0];

xp3=[x-s2-b2,x,rc(1,1),x-s2-b2];
zp3=[0,0,rc(1,3),0];

%yp1=[0 0 0 0 0];
%yp2=[0 0 0 0 0];
%yp3=[0 0 0 0];
%patch(xp1,yp1,zp1,'black');
%patch(xp2,yp2,zp2,'red');
%patch(xp3,yp3,zp3,'blue');
%%%%%%%%%%%%%%%%%


%% fault
l=(x-d)/(n*z);
for i=1:z*n
    for j=1:y*n
        xc = [x, x-l, x-l, x]-l*(i-1);
        yc = [0 0 1/n 1/n]+(j-1)/n;
        zc = [0, 1/n,1/n,0]+(i-1)/n;
        if i/n<rc(1,3)
            rcz=rc(1,3);
            rcx=rc(1,1);
        elseif i/n<rc(4,3)
            rcz=i/n;
            rcx=x-(i-1)*l;
        else
            rcz=rc(4,3);
            rcx=rc(4,1);
        end
        if j/n<rc(1,2)
            rcy=rc(1,2);
        elseif j/n<rc(2,2)
            rcy=j/n;
        else
            rcy=rc(2,2);
        end

        distance=10*sqrt((rcx-(x-(i-1)*l))^2+(rcy-j/n)^2+(rcz-i/n)^2);
        c=color(end-round(distance),:);
        patch(xc,yc,zc,c,'EdgeColor','none')
    end
end

%% top
for i=1:d*n
    for j=1:y*n
        xc = [0, 1/n, 1/n, 0]+(i-1)/n;
        yc = [0 0 1/n 1/n]+(j-1)/n;
        zc = [z, z,z,z];
        if j/n<rc(4,2)
            rcy=rc(4,2);
        elseif j/n<rc(3,2)
            rcy=j/n;
        else
            rcy=rc(3,2);
        end
        rcx=rc(4,1);
        rcz=rc(4,3);

        distance=10*sqrt((rcx-i/n)^2+(rcy-j/n)^2+(rcz-z)^2);
        c=color(end-round(distance),:);
        patch(xc,yc,zc,c,'EdgeColor','none')
    end
end

%% top2
for i=d*n+1:x*n
    for j=1:y*n
        xc = [0, 1/n, 1/n, 0]+(i-1)/n;
        yc = [0 0 1/n 1/n]+(j-1)/n;
        zc = [z, z,z,z];
        if j/n<rc(4,2)
            rcy=rc(4,2);
        elseif j/n<rc(3,2)
            rcy=j/n;
        else
            rcy=rc(3,2);
        end
        rcx=rc(4,1);
        rcz=rc(4,3);

        distance=10*sqrt((rcx-i/n)^2+(rcy-j/n)^2+(rcz-z)^2);
        c=color(end-round(distance),:);
        patch(xc,yc,zc,c,'EdgeColor','none','FaceAlpha',.7)
    end
end

%% side1
for i=1:d*n
    for j=1:z*n
        xc = [0, 1/n, 1/n, 0]+(i-1)/n;
        yc = [0 0 0 0];
        zc = [0 0,1/n,1/n]+(j-1)/n;
        rcy=rc(1,2);
        if inpolygon(i/n,j/n,xp1,zp1)
            rcx=rc(4,1);
            rcz=rc(4,3);
            distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
        elseif inpolygon(i/n,j/n,xp2,zp2)
            distance=10*sqrt((point_to_line_dist([i/n,j/n,0], [rc(1,1) rc(1,3) 0], [rc(4,1) rc(4,3) 0]))^2+rc(1,2)^2);
        elseif inpolygon(i/n,j/n,xp3,zp3)
            rcx=rc(1,1);
            rcz=rc(1,3);
            distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
        end
        c=color(end-round(distance),:);
        patch(xc,yc,zc,c,'EdgeColor','none')
    end
end

%% side2
for i=d*n+1:x*n
    %Triangle
    xc = [0, l, 0]+(i-1)/n;
    yc = [0 0 0];
    j=z*n-2*(i-d*n-1);
    zc = [0 0,1/n]+(j-1)/n;
    rcy=rc(1,2);
    if inpolygon(i/n,j/n,xp1,zp1)
        rcx=rc(4,1);
        rcz=rc(4,3);
        distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
    elseif inpolygon(i/n,j/n,xp2,zp2)
        distance=10*sqrt((point_to_line_dist([i/n,j/n,0], [rc(1,1) rc(1,3) 0], [rc(4,1) rc(4,3) 0]))^2+rc(1,2)^2);
    elseif inpolygon(i/n,j/n,xp3,zp3)
        rcx=rc(1,1);
        rcz=rc(1,3);
        distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
    end
    c=color(end-round(distance),:);
    patch(xc,yc,zc,c,'EdgeColor','none')
    % square and triangle
    xc = [0, 1/n, l, 0]+(i-1)/n;
    yc = [0 0 0 0];
    j=j-1;
    zc = [0 0 1/n 1/n]+(j-1)/n;
    rcy=rc(1,2);
    if inpolygon(i/n,j/n,xp1,zp1)
        rcx=rc(4,1);
        rcz=rc(4,3);
        distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
    elseif inpolygon(i/n,j/n,xp2,zp2)
        distance=10*sqrt((point_to_line_dist([i/n,j/n,0], [rc(1,1) rc(1,3) 0], [rc(4,1) rc(4,3) 0]))^2+rc(1,2)^2);
    elseif inpolygon(i/n,j/n,xp3,zp3)
        rcx=rc(1,1);
        rcz=rc(1,3);
        distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
    end
    c=color(end-round(distance),:);
    patch(xc,yc,zc,c,'EdgeColor','none')

    k=j-1;
    %squares
    for j=1:k
        xc = [0, 1/n, 1/n, 0]+(i-1)/n;
        yc = [0 0 0 0];
        zc = [0 0,1/n,1/n]+(j-1)/n;
        rcy=rc(1,2);
        if inpolygon(i/n,j/n,xp1,zp1)
            rcx=rc(4,1);
            rcz=rc(4,3);
            distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
        elseif inpolygon(i/n,j/n,xp2,zp2)
            distance=10*sqrt((point_to_line_dist([i/n,j/n,0], [rc(1,1) rc(1,3) 0], [rc(4,1) rc(4,3) 0]))^2+rc(1,2)^2);
        elseif inpolygon(i/n,j/n,xp3,zp3)
            rcx=rc(1,1);
            rcz=rc(1,3);
            distance=10*sqrt((rcx-i/n)^2+(rcy-0)^2+(rcz-j/n)^2);
        end
        c=color(end-round(distance),:);
        patch(xc,yc,zc,c,'EdgeColor','none')
    end
end


axis off

%%
%figure
%view(3)
%patch('Faces',[ 1 2 3 4],'Vertices',[0 0 z;d 0 z; d y z; 0 y z],'EdgeColor',[0.6 0.6 0.6],'FaceColor','none','LineWidth',0.1);
%patch('Faces',[ 1 2 3 4],'Vertices',[0 0 0;x 0 0; d 0 z; 0 0 z],'EdgeColor',[0.6 0.6 0.6],'FaceColor','none','LineWidth',0.1);
%patch('Faces',[ 1 2 3 4],'Vertices',[d 0 z;x 0 0; x y 0; d y z],'EdgeColor',[0.6 0.6 0.6],'FaceColor','none','LineWidth',0.1);
%patch('Faces',[ 1 2 3 4],'Vertices',[d 0 z;x 0 z; x y z; d y z],'EdgeColor',[0.6 0.6 0.6],'FaceColor','none','LineWidth',0.1);

patch('Faces',[ 1 2 3 4],'Vertices',[rc(1,:)+[l -1/n -1/n];rc(2,:)+[l 0 -1/n];rc(3,:)+[l 0 -1/n];rc(4,:)+[l -1/n -1/n]],'EdgeColor',[0 0 0],'FaceColor','none','LineWidth',0.1);
hold on
plot3([24 24],[16 16],[2*(x-24) 20],'black')

%patch('Faces',[ 1 2 3 4],'Vertices',[0 0 z*1.01;x 0 z*1.01; x y/1.5 z*1.01; 0 y/1.5 z*1.01],'EdgeColor','none','FaceColor','blue','LineWidth',0.1);

toc
