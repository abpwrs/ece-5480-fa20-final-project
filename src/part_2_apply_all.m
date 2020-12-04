% ECE:5480 Digital Image Processing
% Final Project Part Two
% Mikayla Biggs & Alexander Powers

% Read in Coin Images
src_dir = pwd();
filesep_idx = strfind(src_dir, filesep);
data_folder = strcat(src_dir(1:filesep_idx(end)), 'data/');
report_images_folder = strcat(src_dir(1:filesep_idx(end)), 'report/images/');

files = dir(strcat(data_folder,'*.jpg'));
failure_count = 0;
failures = [];
failure_index = 1;
for file_index=1:length(files)
    close all;
    file_obj = files(file_index)
    figure_dir = strcat(report_images_folder, file_obj.name(1:end-4), filesep);
    if ~isfolder(figure_dir)
        mkdir(figure_dir);
    end
    
    existing_figures = dir(strcat(figure_dir, '*.png'));
    figures_exist = numel(existing_figures) == 6
    if ~figures_exist
        try
            done = tmp_part2_func(file_obj, data_folder, figure_dir) ;
        catch exception
            done = 0;
            failure_count = failure_count + 1;
            failures = [failures "" file_obj.name];
            failure_index = failure_index + 1;
        end
        done
    end
    
end

failure_count
failures