function [rect_img] = drawRectWidthHeight( img, x, width, y, height )
    x=round(x);
    y=round(y);
    width=round(width);
    height=round(height);
    rect_img = img;
    rect_img(x:x+width,y,:)=255;
    rect_img(x:x+width,y+height,:)=255;
    rect_img(x,y:y+height,:)=255;
    rect_img(x+width,y:y+height,:)=255;
end