param($month_value)

$global:source_path = $home + '\Desktop\сканы' 

$global:destination_path = $home + '\Desktop\result_test\'                              

$month_mask = @{
    January = "^\d+-\w+-\d{2}\.01\.\d{4}\.pdf$"
    February = "^\d+-\w+-\d{2}\.02\.\d{4}\.pdf$"
    March = "^\d+-\w+-\d{2}\.03\.\d{4}\.pdf$" 
    April = "^\d+-\w+-\d{2}\.04\.\d{4}\.pdf$"
    May = "^\d+-\w+-\d{2}\.05\.\d{4}\.pdf$"
    June = "^\d+-\w+-\d{2}\.06\.\d{4}\.pdf$"
    July = "^\d+-\w+-\d{2}\.07\.\d{4}\.pdf$"
    August = "^\d+-\w+-\d{2}\.08\.\d{4}\.pdf$"
    September = "^\d+-\w+-\d{2}\.09\.\d{4}\.pdf$"
    October = "^\d+-\w+-\d{2}\.10\.\d{4}\.pdf$"
    November = "^\d+-\w+-\d{2}\.11\.\d{4}\.pdf$"
    December = "^\d+-\w+-\d{2}\.12\.\d{4}\.pdf$"
}

$eias_month_mask = ("^\d{5}-\d{2}-\d{2}-\d{2}\.01\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.02\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.03\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.04\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.05\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.06\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.07\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.08\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.09\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.10\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.11\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.12\.\d{4}\.pdf$")

$monthes_folders_names = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь') 

$log_files_names = ('.\january_backup_log.txt', '.\february_backup_log.txt', '.\march_backup_log.txt', '.\april_backup_log.txt', '.\may_backup_log.txt', '.\june_backup_log.txt', 
                    '.\july_backup_log.txt', '.\august_backup_log.txt', '.\september_backup_log.txt', '.\october_backup_log.txt', '.\november_backup_log.txt', '.\december_backup_log.txt')

$global:log_file

function backuping_files ($file_mask, $eias_file_mask, $folder_name) {
    $result_folder = $destination_path + $folder_name
    $simple_files_count = 0; $eias_files_count = 0
                        
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | Copy-Item -Destination $result_folder 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object Name | Out-File -FilePath $log_file
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object {$simple_files_count += 1}
                        
    $file_mask = $eias_file_mask
                    
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | Copy-Item -Destination $result_folder 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object Name | Out-File -FilePath $log_file -Append
    Get-ChildItem -Path $source_path | Where-Object Name -Match $file_mask | ForEach-Object {$eias_files_count += 1}
                            
    $result_count = "`n Количество скопированных файлов: " + ($simple_files_count + $eias_files_count)
    $result_count | Out-File -FilePath $log_file -Append
}

if ($month_value -eq 01) {
    $log_file = $log_files_names[0]

    backuping_files $month_mask.January $eias_month_mask[0] $monthes_folders_names[0]
}
elseif ($month_value -eq 02) {
    $log_file = $log_files_names[1]

    backuping_files $month_mask.February $eias_month_mask[1] $monthes_folders_names[1]
}





