function [input1, output1, input2, output2] = computePoints(im)
%COMPUTEPOINTS Compute for the contrast stretching showing the visual
%changes of the image
%
% ---INPUT---
% im                 - input image
% ---OUTPUT---
% input1, input2     - values of input intensity level
% output1, output2   - values of output intensity level

im(:,:,2)=im(:,:,1);
im(:,:,3)=im(:,:,1);

imshow(im);
title("Original");

im=rgb2hsv(im);

V=im(:,:,3)*255;

global r1;
global s1;
global r2;
global s2;

global ht1;
global ht2;
global ht3;
global ht4;

r1=20; %lower threshold x
s1=0; %lower threshold y
r2=220; %upper threshold x
s2=255; %upper threshold y

t1=V>r1;
V1=(s1/r1)*V;
V1(t1==1)=0;
t1=V<=r1;
t2=V>r2;
V2=((s2-s1)/(r2-r1))*(V-r1)+s1;
V2(t1==1)=0;
V2(t2==1)=0;
t2=V<=r2;
V3=((255-s2)/(255-r2))*(V-255)+255;
V3(t2==1)=0;
V_tot=V1+V2+V3;

figure
imhandle1=imshow(V_tot,[]);
title("V channel");

im(:,:,3)=mat2gray(V-V_tot);
im=hsv2rgb(im);
im=uint8(im*255);

n2=figure;
imhandle2=imshow(im);
title("Result");

figure(n2);
n2.Position(3:4) = [572, 382];
set(n2,'CloseRequestFcn');

% labels for the sliders
lab1 = uicontrol('style','text','String','intensity input 1','Position',[40,96,102,17]);
lab2 = uicontrol('style','text','String','intensity output 1','Position',[290,96,102,17]);
lab3 = uicontrol('style','text','String','intensity input 2','Position',[40,40,102,17]);
lab4 = uicontrol('style','text','String','intensity output 2','Position',[290,40,102,17]);

% sliders and text boxes
ht1 = uicontrol('style','text','String',r1,'Position',[10,77,40,15]);
hs1 = uicontrol('Style','slider','Min',0,'Max',255,...
                'SliderStep',[1 1]./255,'Value',r1,...
                'Position',[50,75,200,20]);
ht2 = uicontrol('style','text','String',s1,'Position',[260,77,40,15]);
hs2 = uicontrol('Style','slider','Min',0,'Max',255,...
                'SliderStep',[1 1]./255,'Value',s1,...
                'Position',[300,75,200,20]);
ht3 = uicontrol('style','text','String',r2,'Position',[10,25,40,15]);
hs3 = uicontrol('Style','slider','Min',0,'Max',255,...
                'SliderStep',[1 1]./255,'Value',r2,...
                'Position',[50,20,200,20]);
ht4 = uicontrol('style','text','String',s2,'Position',[260,25,40,15]);
hs4 = uicontrol('Style','slider','Min',0,'Max',255,...
                'SliderStep',[1 1]./255,'Value',s2,...
                'Position',[300,20,200,20]);

% the button assign the values of the sliders to the variables r1, r2, s1
% and s2 and closes the figure n2
PushButton = uicontrol(gcf,'Style', 'push', 'String', 'Next','Position', [514,38,40,40],'Callback',@(src,evnt)pushButton());
     
% callbacks of the sliders, when the value of a sliders changes the new
% contrast is recomputed
set(hs1,'Callback',@(hObject,eventdata) contrastStretch(V,hs1.Value,hs2.Value,hs3.Value,hs4.Value,imhandle1,imhandle2))
set(hs2,'Callback',@(hObject,eventdata) contrastStretch(V,hs1.Value,hs2.Value,hs3.Value,hs4.Value,imhandle1,imhandle2))
set(hs3,'Callback',@(hObject,eventdata) contrastStretch(V,hs1.Value,hs2.Value,hs3.Value,hs4.Value,imhandle1,imhandle2))
set(hs4,'Callback',@(hObject,eventdata) contrastStretch(V,hs1.Value,hs2.Value,hs3.Value,hs4.Value,imhandle1,imhandle2))

% the value of the slider is written in the text boxes
fun1 = @(~,e)set(ht1,'String',num2str(get(e.AffectedObject,'Value')));
addlistener(hs1, 'Value', 'PostSet',fun1);
fun2 = @(~,e)set(ht2,'String',num2str(get(e.AffectedObject,'Value')));
addlistener(hs2, 'Value', 'PostSet',fun2);
fun3 = @(~,e)set(ht3,'String',num2str(get(e.AffectedObject,'Value')));
addlistener(hs3, 'Value', 'PostSet',fun3);
fun4 = @(~,e)set(ht4,'String',num2str(get(e.AffectedObject,'Value')));
addlistener(hs4, 'Value', 'PostSet',fun4);

% wait for the figure n2 to be closed
waitfor(n2);

% the value of the global values are assigned to the output values of the
% function because an input or output global value might not be supported 
% in a future release
input1 = r1;
input2 = r2;
output1 = s1;
output2 = s2;

end

% compute contrast using the values of the sliders
function contrastStretch(V,r1,s1,r2,s2,imhandle1,imhandle2)
t1=V>r1;
V1=(s1/r1)*V;
V1(t1==1)=0;
t1=V<=r1;
t2=V>r2;
V2=((s2-s1)/(r2-r1))*(V-r1)+s1;
V2(t1==1)=0;
V2(t2==1)=0;
t2=V<=r2;
V3=((255-s2)/(255-r2))*(V-255)+255; %transform function
V3(t2==1)=0; %clipping
V_tot=V1+V2+V3;

set(imhandle1, 'CData', V_tot);

im(:,:,3)=mat2gray(V-V_tot);
im=hsv2rgb(im);
im=uint8(im*255);

set(imhandle2, 'CData', im);

end

% assigns the values of the sliders to the values r1, r2, s1 and s2 and
% closes the figure n2
function pushButton()
global r1;
global s1;
global r2;
global s2;
global ht1;
global ht2;
global ht3;
global ht4;

r1 = str2double(ht1.String);
s1 = str2double(ht2.String);
r2 = str2double(ht3.String);
s2 = str2double(ht4.String);

close(get(ht1,'Parent'))
end