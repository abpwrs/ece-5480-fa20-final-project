function ret = rmfilter(I)
    % INIT m and v
    m = zeros(size(I, 1), size(I, 2), 8);
    v = zeros(size(I, 1), size(I, 2), 8);

    % define functions
    fun = @fm;
    fun2 = @fv;

    % apply functions
    m(:,:,1) = nlfilter(I, [5 5], fun, 1);
    v(:,:,1) = nlfilter(I, [5 5], fun2, 1);

    m(:,:,2) = nlfilter(I, [5 5], fun, 2);
    v(:,:,2) = nlfilter(I, [5 5], fun2, 2);

    m(:,:,3) = nlfilter(I, [5 5], fun, 3);
    v(:,:,3) = nlfilter(I, [5 5], fun2, 3);

    m(:,:,4) = nlfilter(I, [5 5], fun, 4);
    v(:,:,4) = nlfilter(I, [5 5], fun2, 4);

    m(:,:,5) = nlfilter(I, [5 5], fun, 5);
    v(:,:,5) = nlfilter(I, [5 5], fun2, 5);

    m(:,:,6) = nlfilter(I, [5 5], fun, 6);
    v(:,:,6) = nlfilter(I, [5 5], fun2, 6);

    m(:,:,7) = nlfilter(I, [5 5], fun, 7);
    v(:,:,7) = nlfilter(I, [5 5], fun2, 7);    

    m(:,:,8) = nlfilter(I, [5 5], fun, 8);
    v(:,:,8) = nlfilter(I, [5 5], fun2, 8);

    [~, In] = min(v, [], 3);

    [x, y] = ind2sub(size(I), (1:size(I, 1)*size(I, 2))');
    z = In(:);
    idx = sub2ind(size(v), uint32(x), uint32(y), uint32(z));

    S = m(idx);
    ret = reshape(S, size(I));
end

function mean_value = fm(x,n)
    x = double(x);
    [xind, yind] = get_top_left_index_from_n(n);
    mean_value = mean(x(xind:xind+2,yind:yind+2), 'all');
end

function dispersion_value = fv(x,n)
    x = double(x);
    [xind, yind] = get_top_left_index_from_n(n);
    dispersion_value = var(x(xind:xind+2,yind:yind+2), 1, 'all');
end

function [xind, yind] = get_top_left_index_from_n(n)
    switch n
        case 1
            xind = 1;
            yind = 3;
        case 2
            xind = 1;
            yind = 2;
        case 3
            xind = 1;
            yind = 1;
        case 4
            xind = 2;
            yind = 1;
        case 5
            xind = 3;
            yind = 1;
        case 6
            xind = 3;
            yind = 2;
        case 7
            xind = 3;
            yind = 3;
        case 8
            xind = 2;
            yind = 3;
    end
end


