str = 'D:\video\';
files = dir(strcat(str,'*.mp4'));
number_files = length(files);
Xall = cell(1,number_files); % 初始化存储所有视频所有帧的特质值元胞
for i=1:number_files
    Xall{1,i} = video2features( [str, files(i).name] );
end
xall = cell2mat(Xall);

function [Video_xfeatures] = video2features( VIBEtestOutVideo )
%opencv GLCM
% 5*4*2 
% Video red_rect_vertex 
allxfea=@( Irear )cellfun( @( th,d )computeXfeature( Irear,th,d ),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false );
v = VideoReader( VIBEtestOutVideo ); 
    vW=v.Width;
    frame_order=0;
    Video_xfeatures=zeros( v.NumFrames,80 );
while hasFrame( v )
 frame_order=frame_order+1;
 frame = readFrame( v );
    frame = frame( sum( all( frame==255,2 ),3 )~=3, :, : ); % 裁去下方( 纵向 )白色区域，将视频中有车的部分提取出来
    frame = frame( :, sum( all( frame==255,1 ),3 )~=3, : ); % 裁去右方( 横向 )白色区域，将视频中有车的部分提取出来
 framerear = reardet( frame,vW );
    med = round( size( framerear,2 )/2 );
    Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
end
Video_xfeatures = Video_xfeatures';
end