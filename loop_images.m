function loop_images( images, loop_forever )
    continue_loop = true;
    while (continue_loop)
       continue_loop = false;
       for i = 1:size(images,1)
           imshow(images{i,1});
           fprintf('%d of %d', i, size(images,1));
           if (size(images,2)==2)
               fprintf('\tScore = %f\n',images{i,2});
           else
               fprintf('\n');
           end
           pause(0.25);
       end
       if (loop_forever)
            fprintf('--Press any button to repeat.--\n\n');
            continue_loop = true;
            pause;
       end
    end
end