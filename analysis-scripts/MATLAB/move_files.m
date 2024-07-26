% jul 2024 prepare pilot A 
ls 

results_dir = '../../results/';
mkdir([results_dir '/PilotA'])
ls(results_dir)

path_info  = readtable('path_info_PilotA');


orig_dir = [results_dir '/expt1-expt2/'];
new_dir = [results_dir '/PilotA/'];



all_fnames = [path_info.task; path_info.taskcontin; path_info.studycontin; path_info.explicit; path_info.familiarity];

for f = 1:numel(all_fnames)
    fname = all_fnames{f};
    fpath = [orig_dir '/' fname '.txt'];
    
 
    if exist(fpath,"file")
        unix(['rsync -av ' fpath ' ' new_dir '/' fname '.txt'])


    else 
        warning('file not found:')
        fname 
    end 
      
end 


