%% 第一部分为格式转换读取rho

% 从记录文档中读取数据，记录时代码为writematrix(H.rho);这个指令会将H.rho写为一个
% 名为matrix.txt的文件，三维矩阵以二维形式记录，若直接使用rho矩阵请注释掉该部分，
% 另外定义rho与X.rho一致，已测试过si2和si8的数据
matrix = load('C:\Users\86183\Desktop\gui\matrix 1.txt');  % 此处填写调用的文件地址
[xs ys]=size(matrix);
for i=1:xs
    rho(:,:,i)=matrix(:,xs*i-xs+1:xs*i);  % 还原回三维矩阵
end

%% 第二部分为将原矩阵通过线性插值拓展为更大的矩阵，画图时将更美观

% kssolv内每格点大小应为1bohr=0.5291772083A
bohr=0.5291772083;
rho=rho/bohr^3;                       % 调整密度单位为/A^3
[xs,ys,zs] = size(rho);
Nx=50;                                % 将格点增至50以上避免模糊
Ny=50;
Nz=50;
dx=(Nx-mod(Nx,xs))/xs+1;              % x部分，将rho拓展后得到rho1

for i=1:xs-1
    for j=1:dx
    rho1((i-1)*dx+j,:,:)=rho(i+1,:,:).*(j-1)/dx+rho(i,:,:).*(dx-j+1)/dx;
    end
end
rho1(dx*(xs-1)+1,:,:)=rho(xs,:,:);
dy=(Ny-mod(Ny,ys))/ys+1;              % y部分，将rho1拓展后得到rho2
for i=1:ys-1
    for j=1:dy
    rho2(:,(i-1)*dy+j,:)=rho1(:,i+1,:).*(j-1)/dy+rho1(:,i,:).*(dx-j+1)/dy;
    end
end
rho2(:,dy*(ys-1)+1,:)=rho1(:,ys,:);
dz=(Nz-mod(Nz,zs))/zs+1;              % z部分，将rho2拓展后得到rho3
for i=1:zs-1
    for j=1:dz
    rho3(:,:,(i-1)*dz+j)=rho2(:,:,i+1).*(j-1)/dz+rho2(:,:,i).*(dx-j+1)/dz;
    end
end
rho3(:,:,dz*(zs-1)+1)=rho2(:,:,zs);

[xs1,ys1,zs1] = size(rho3);           % 记录拓展后的矩阵大小

%% 第三部分为画图部分

% 第一张图为电荷密度截面图
figure(1)
[X,Y,Z] = meshgrid(0:1/dx:xs-1,0:1/dy:ys-1,0:1/dz:zs-1);
X=bohr*X;                             % 调整坐标单位为A
Y=bohr*Y;
Z=bohr*Z;
% 指定h,k,l为密勒指数，d为切面到原点的距离
h=1;
k=1;
l=1;
d=30;                                 % d单位为A
% 平面方程hx + ky + lz - d * sqrt(h^2 + k^2 + l^2) = 0
% 选定切面范围首先设定完整切面，完整切面网格可取细致一些防止画图时锯齿
if l~=0
[xsurf,ysurf]=meshgrid(0:0.2/dx:xs-1,0:0.2/dy:ys-1); % 将meshgrid内的网格间隔取小即可增加格点
zsurf = (d * sqrt(h^2 + k^2 + l^2)-h*xsurf-k*ysurf)./l;
elseif k~=0
[xsurf,zsurf]=meshgrid(0:0.2/dx:xs-1,0:0.2/dz:zs-1);
ysurf = (d * sqrt(h^2 + k^2 + l^2)-h*xsurf-l*zsurf)./k;
elseif h~=0
[ysurf,zsurf]=meshgrid(0:0.2/dy:ys-1,0:0.2/dz:zs-1);
xsurf = (d * sqrt(h^2 + k^2 + l^2)-k*ysurf-l*zsurf)./h;  
end
[xsurfs,ysurfs]=size(xsurf);          % 记录完整切面大小
% 从切面中删除晶胞外的数据，将其设为inf数不参与画图
for i=1:xsurfs
    for j=1:ysurfs
        if xsurf(i,j)<0||xsurf(i,j)>xs-1|| ysurf(i,j)<0||ysurf(i,j)>ys-1|| zsurf(i,j)<0||zsurf(i,j)>zs-1
xsurf(i,j)=inf;
ysurf(i,j)=inf;
zsurf(i,j)=inf;
        end
    end
end
xsurf=bohr*xsurf;                     % 调整坐标单位为A
ysurf=bohr*ysurf;
zsurf=bohr*zsurf;
slice(X,Y,Z,rho3,xsurf,ysurf,zsurf)   % 做切面差分图
grid off
view([-h -k -l]);                     % 调整视角，视角内选择期望方向的负值
xlabel('X axis/A')
ylabel('Y axis/A')                    % 坐标轴命名
zlabel('Z axis/A')
xlim([0, bohr*(xs-1)]);               % 限制坐标范围为晶胞范围
ylim([0, bohr*(zs-1)]);
zlim([0, bohr*(zs-1)]);
shading flat                          % 去除画图网格
colorbar;                             % 增加颜色标度尺
c = colorbar;
c.Label.String = '\rho /A^3';         % 颜色标度尺和图像命名
title(sprintf('h=%.2f,k=%.2f,l=%.2f,d=%.2fA', h,k,l,d));

% 第二张图为电荷密度等值面图，matlab自带等值面设置
figure(2)
isosurface(X,Y,Z,rho3,0.9*max(max(max(rho3)))) % 对等值面作图，等值面为0.9倍电子密度最大值
% 这个等值面应该可以修改颜色和透明度，但patch调用时总是报参数错误（应该和等值面数目过多有关），我暂时无法解决，等后续改良
hold on
isosurface(X,Y,Z,rho3,0.1*max(max(max(rho3)))) % 对等值面作图，等值面为0.1倍电子密度最大值
alpha(0.5)                            %设置透明度为0.5
hold off
view([-h -k -l]);                     % 调整视角
% camtarget([d / sqrt(h^2 + k^2 + l^2)*h,d / sqrt(h^2 + k^2 + l^2)*k,d / sqrt(h^2 + k^2 + l^2)*l]) 
% % 此为固定设立相机位置，设置后图片将无法转动
xlabel('X axis/A')                    % 坐标轴命名
ylabel('Y axis/A')
zlabel('Z axis/A')
xlim([0, bohr*(xs-1)]);               % 限制坐标范围为晶胞范围
ylim([0, bohr*(zs-1)]);
zlim([0, bohr*(zs-1)]);               % 去除画图网格
colorbar;                             % 增加颜色标度尺
c = colorbar;
c.Label.String = '\rho /A^3';         % 颜色标度尺和图像命名
shading flat
title('电子密度等值面');

%%