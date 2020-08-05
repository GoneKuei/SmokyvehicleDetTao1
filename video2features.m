function [Video_xfeatures,YieldRate] = video2features( VIBEtestOutVideo )
%opencv GLCM
% 5*4*2 
% Video red_rect_vertex 
allxfea=@( Irear )cellfun( @( th,d )computeXfeature( Irear,th,d ),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false );
v = VideoReader( VIBEtestOutVideo ); 
    vW=v.Width;
    frame_order=0;
    Video_xfeatures= -ones( v.NumFrames,80 );
while hasFrame( v )
 frame_order=frame_order+1;
 frame = readFrame( v );
    frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % ��ȥ�·�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % ��ȥ�ҷ�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    [h,w,~] = size(frame);
    if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
        framerear = reardet( frame,vW );
        if  size(framerear,1)>=60*(vW/768)% �жϳ�β������ﵽ50����60��
            med = round( size( framerear,2 )/2 );
            Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
%             imshow(frame);
        end
    end
end
Video_xfeatures = Video_xfeatures( ~all( Video_xfeatures==-1,2 ), :)'; % ɾ��
YieldRate = size(Video_xfeatures,2)./v.NumFrame;
end