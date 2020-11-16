function ret = optithd(I)

mask = ones(size(I));
mask(1,1) = 0;
mask(1,end) = 0;
mask(end, 1) = 0;
mask(end, end) = 0;
mask = mask>0;

thd = -1e10;

while true
    thd_old = thd;

    obj = mean(I(mask));
    bg  = mean(I(~mask));
    thd = mean([ obj bg ]);
    mask = I>thd;
    if abs(thd-thd_old)<1
        break
    end
end

ret = I>thd;
end

