function [rect_img] = drawRect_colourByScore( img, score, x1, y1, x2, y2, line_padding )
    minimum_score = -0.5;
    maximum_score = 1.5;
    x1=round(x1);
    y1=round(y1);
    x2=round(x2);
    y2=round(y2);
    rect_img = img;
    map_index = max(1,min(round(40*(score+0.5)),80));
    cmap = jet(80);
    close(figure(1));
    fprintf('from %f to %f',max(y1-line_padding,1),min(y1+line_padding,size(img,1)));
    disp(cmap(map_index,1));
    disp(cmap(map_index,2));
    disp(cmap(map_index,3));
    rect_img(max(y1-line_padding,1):min(y1+line_padding,size(img,1)),x1:x2,1)=255*cmap(map_index,1);
    rect_img(max(y2-line_padding,1):min(y2+line_padding,size(img,1)),x1:x2,1)=255*cmap(map_index,1);
    rect_img(y1:y2,max(x1-line_padding,1):min(x1+line_padding,size(img,2)),1)=255*cmap(map_index,1);
    rect_img(y1:y2,max(x2-line_padding,1):min(x2+line_padding,size(img,2)),1)=255*cmap(map_index,1);
    rect_img(max(y1-line_padding,1):min(y1+line_padding,size(img,1)),x1:x2,2)=255*cmap(map_index,2);
    rect_img(max(y2-line_padding,1):min(y2+line_padding,size(img,1)),x1:x2,2)=255*cmap(map_index,2);
    rect_img(y1:y2,max(x1-line_padding,1):min(x1+line_padding,size(img,2)),2)=255*cmap(map_index,2);
    rect_img(y1:y2,max(x2-line_padding,1):min(x2+line_padding,size(img,2)),2)=255*cmap(map_index,2);
    rect_img(max(y1-line_padding,1):min(y1+line_padding,size(img,1)),x1:x2,3)=255*cmap(map_index,3);
    rect_img(max(y2-line_padding,1):min(y2+line_padding,size(img,1)),x1:x2,3)=255*cmap(map_index,3);
    rect_img(y1:y2,max(x1-line_padding,1):min(x1+line_padding,size(img,2)),3)=255*cmap(map_index,3);
    rect_img(y1:y2,max(x2-line_padding,1):min(x2+line_padding,size(img,2)),3)=255*cmap(map_index,3);
end

