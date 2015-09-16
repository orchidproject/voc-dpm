function [rect_img] = drawRect( img, x1, y1, x2, y2 )
    x1=round(x1);
    y1=round(y1);
    x2=round(x2);
    y2=round(y2);
    rect_img = img;
    rect_img(y1,x1:x2,:)=255;
    rect_img(y2,x1:x2,:)=255;
    rect_img(y1:y2,x1,:)=255;
    rect_img(y1:y2,x2,:)=255;
end