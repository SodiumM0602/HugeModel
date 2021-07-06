
function get_data_gam(opts)  
% This function is used to generate spectrogram from draw audio file
% input format: file.wav 
% output format: an image with shape of nTxnF
% NOTE: + The class folders are generated automatically
%       + The file name will be renamed that is shape <class_name>_<001>.mat

%=================== Parameters for Gammatone filter Spectrogram
res_fs = 16000;
time_dur = 5;

gam_fil_num = 64;     %Default: 128
window_size = 0.025;    %Default: 0.025
hop_size    = window_size/2; %Default: 0.005
min_freq    = 50;      %Default: 10
gam_opt     = 1;       %Default:1 --> Read the tool for futher explaination

wc_cyc_num = 0; 
c_cyc_num  = 0;
w_cyc_num  = 0;
n_cyc_num  = 0;
%=================== Behavior

% 01/ Setup directory
data_txt_dir   = opts.data_txt;  
data_audio_dir = opts.data_audio;  
store_dir_C    = opts.store_dir_C;
store_dir_W    = opts.store_dir_W;
store_dir_B    = opts.store_dir_B;
store_dir_N    = opts.store_dir_N;


file_dir = [data_audio_dir, '/'];
file_struct = dir(file_dir);
file_name_list = {file_struct.name};  
file_name_list(strncmp(file_name_list,'.',1))=[];%remove files that start with a dot  
[nRow, file_num] = size(file_name_list);
%--------------------------------------------------------------------------------  
for nFile = 1:file_num  
    file_name = file_name_list{nFile};
    [filepath,new_file_name,ext] = fileparts(file_name);
    %new_file_name
    %pause

    %Read draw audio file
    [org_wav,fs]=audioread([file_dir, file_name_list{nFile}]); 

    %Resample 
    org_wav = resample(org_wav, res_fs, fs);

    limit_num = time_dur*res_fs;
    file_txt_open = [data_txt_dir,new_file_name,'.txt'];
    file_txt_p = fopen(file_txt_open, 'r');
    cyc_in_file = 1;
    while true
        this_line = fgetl(file_txt_p);
        if ~ischar(this_line);
            break;
        end
        C = textscan(this_line, '%f %f %f %f');
        time_st = cell2mat(C(1));
        time_ed = cell2mat(C(2));
        is_C    = cell2mat(C(3));
        is_W    = cell2mat(C(4));
        id_st   = int64(time_st*res_fs) + 1;
        id_ed   = int64(time_ed*res_fs);
        data = org_wav(id_st:id_ed); 
     
        %Solve issue of data length
        org_cyc_length = id_ed - id_st;
        new_data = data;
        if(org_cyc_length < limit_num);
            while(1);
                new_data = [new_data; data];
                [new_data_len, col] = size(new_data);
                if(new_data_len >= limit_num);
                    new_data = new_data(1:limit_num);
                    break
                end
            end
        else
            new_data = new_data(1:limit_num);
        end
        
        %Convert into spectrogram
        new_data = new_data + eps;
        [D,~] =  gammatonegram(new_data, res_fs, window_size, hop_size, gam_fil_num, min_freq, res_fs/2, gam_opt);
        [row, col] = size(D);
        %pause
        if((col ~= 311) && (row ~= 64));
            fprintf('ERROR Col dimenssion at file %s: %d, %d \n', file_name, row, col);
            pause
        end

         %File save 
         if(is_C && is_W);
             file_save = [store_dir_B, new_file_name, '_B_',  num2str(cyc_in_file)]; 
             wc_cyc_num = wc_cyc_num + 1;
         elseif(is_C);
             file_save = [store_dir_C, new_file_name, '_C_', num2str(cyc_in_file)]; 
             c_cyc_num = c_cyc_num + 1;
         elseif(is_W);
             file_save = [store_dir_W, new_file_name, '_W_', num2str(cyc_in_file)]; 
             w_cyc_num = w_cyc_num + 1;
         else
             file_save = [store_dir_N, new_file_name, '_N_', num2str(cyc_in_file)]; 
             n_cyc_num = n_cyc_num + 1;
         end

         clear final_data;
         final_data = D;
         %pause

         save(file_save, 'final_data');  
         cyc_in_file = cyc_in_file + 1;
         %pause

    end %end while
fclose('all');
end % end of all files

fprintf('======================= Done extracting \n');  
wc_cyc_num
c_cyc_num
w_cyc_num
n_cyc_num
wc_cyc_num + c_cyc_num + w_cyc_num + n_cyc_num
end %function  
