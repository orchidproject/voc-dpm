function loop_images( images )
    while (true)
       for i = 1:numel(images)
           imshow(images{i});
           fprintf('%d of %d\n', i, numel(images));
           pause(0.1);
       end
    end
end