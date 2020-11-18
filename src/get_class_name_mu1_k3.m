function name = get_class_name_mu1_k3(mu1, mu2, mu3)
    if mu1 > mu2 && mu1 > mu3
        name=sprintf('quarters');
    else
        if mu1 > mu2 || mu1 > mu3
            name=sprintf('pennies');
        else
            name=sprintf('dimes');
        end
    end
end