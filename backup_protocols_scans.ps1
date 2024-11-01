param($month_value)

$source_path = $home + '\Desktop\сканы' 

$destination_path = $home + '\Desktop\result_test\'                              

$month_mask = ("^\d+-\w+-\d{2}\.01\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.02\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.03\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.04\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.05\.\d{4}\.pdf$",
               "^\d+-\w+-\d{2}\.06\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.07\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.08\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.09\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.10\.\d{4}\.pdf$", 
               "^\d+-\w+-\d{2}\.11\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.12\.\d{4}\.pdf$")

$eias_month_mask = ("^\d{5}-\d{2}-\d{2}-\d{2}\.01\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.02\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.03\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.04\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.05\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.06\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.07\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.08\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.09\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.10\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.11\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.12\.\d{4}\.pdf$")

$monthes_folders_names = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь') 

$log_files_names = ('.\january_backup_log.txt', '.\february_backup_log.txt', '.\march_backup_log.txt', '.\april_backup_log.txt', '.\may_backup_log.txt', '.\june_backup_log.txt', 
                    '.\july_backup_log.txt', '.\august_backup_log.txt', '.\september_backup_log.txt', '.\october_backup_log.txt', '.\november_backup_log.txt', '.\december_backup_log.txt')


function backuping_files ($file_mask, $eias_file_mask, $folder_name) {
    $simple_files_count = 0; $eias_files_count = 0
                        
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | Copy-Item -Destination $destination_path$folder_name 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object Name | Out-File -FilePath $log_file
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object {$simple_files_count += 1}
                        
    $file_mask = $eias_file_mask
                    
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | Copy-Item -Destination $destination_path$folder_name 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object Name | Out-File -FilePath $log_file -Append
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object {$eias_files_count += 1}
                            
    $result_count = "`n Количество скопированных файлов: " + ($simple_files_count + $eias_files_count)
    $result_count | Out-File -FilePath $log_file -Append
}


function logging_backup ()


function backuping_per_year {
    $i = 0
    
    while ($i -le 11) {
        $log_file = $log_files_names[$i]

        backuping_files $month_mask[$i] $eias_month_mask[$i] $monthes_folders_names[$i]

        $i++
    }
}


if ($month_value -eq 01) {
    $log_file = $log_files_names[0]

    backuping_files $month_mask[0] $eias_month_mask[0] $monthes_folders_names[0]
}
elseif ($month_value -eq 02) {
    $log_file = $log_files_names[1]

    backuping_files $month_mask[1] $eias_month_mask[1] $monthes_folders_names[1]
}
elseif ($month_value -eq 03) {
    $log_file = $log_files_names[2]

    backuping_files $month_mask[2] $eias_month_mask[2] $monthes_folders_names[2]
}
elseif ($month_value -eq 04) {
    $log_file = $log_files_names[3]

    backuping_files $month_mask[3] $eias_month_mask[3] $monthes_folders_names[3]
}
elseif ($month_value -eq 05) {
    $log_file = $log_files_names[4]

    backuping_files $month_mask[4] $eias_month_mask[4] $monthes_folders_names[4]
}
elseif ($month_value -eq 06) {
    $log_file = $log_files_names[5]

    backuping_files $month_mask[5] $eias_month_mask[5] $monthes_folders_names[5]
}
elseif ($month_value -eq 07) {
    $log_file = $log_files_names[6]

    backuping_files $month_mask[6] $eias_month_mask[6] $monthes_folders_names[6]
}
elseif ($month_value -eq 08) {
    $log_file = $log_files_names[7]

    backuping_files $month_mask[7] $eias_month_mask[7] $monthes_folders_names[7]
}
elseif ($month_value -eq 09) {
    $log_file = $log_files_names[8]

    backuping_files $month_mask[8] $eias_month_mask[8] $monthes_folders_names[8]
}
elseif ($month_value -eq 10) {
    $log_file = $log_files_names[9]

    backuping_files $month_mask[9] $eias_month_mask[9] $monthes_folders_names[9]
}
elseif ($month_value -eq 11) {
    $log_file = $log_files_names[10]

    backuping_files $month_mask[10] $eias_month_mask[10] $monthes_folders_names[10]
}
elseif ($month_value -eq 12) {
    $log_file = $log_files_names[11]

    backuping_files $month_mask[11] $eias_month_mask[11] $monthes_folders_names[11]
}
