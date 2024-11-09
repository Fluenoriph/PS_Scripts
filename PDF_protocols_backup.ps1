# Nebula Backup PDF
# (c) Ivan Bogdanov


$source_path = $home + '\Desktop\сканы'               # Изменить !

$destination_path = $home + '\Desktop\result_test\'   # Изменить !         
     
$folders_names = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь') 

$log_files_names = ('.\logs\january_backup_log.txt', '.\logs\february_backup_log.txt', '.\logs\march_backup_log.txt', '.\logs\april_backup_log.txt', '.\logs\may_backup_log.txt', 
                    '.\logs\june_backup_log.txt', '.\logs\july_backup_log.txt', '.\logs\august_backup_log.txt', '.\logs\september_backup_log.txt', '.\logs\october_backup_log.txt', 
                    '.\logs\november_backup_log.txt', '.\logs\december_backup_log.txt')
                    
$file_mask = ("^\d+-\w+-\d{2}\.01\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.02\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.03\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.04\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.05\.\d{4}\.pdf$",
               "^\d+-\w+-\d{2}\.06\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.07\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.08\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.09\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.10\.\d{4}\.pdf$", 
               "^\d+-\w+-\d{2}\.11\.\d{4}\.pdf$", "^\d+-\w+-\d{2}\.12\.\d{4}\.pdf$")

$eias_file_mask = ("^\d{5}-\d{2}-\d{2}-\d{2}\.01\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.02\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.03\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.04\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.05\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.06\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.07\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.08\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.09\.\d{4}\.pdf$", 
                    "^\d{5}-\d{2}-\d{2}-\d{2}\.10\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.11\.\d{4}\.pdf$", "^\d{5}-\d{2}-\d{2}-\d{2}\.12\.\d{4}\.pdf$")

$global:count = 0; $global:year_sum = 0

$separatop = '- - - - - - - - - - - - - - - - - - - - - - - - - - - -'
$print_separator = Write-Output $separatop


Write-Output @"
$print_separator  
    >> Резервное копирование сканов протоколов << 
$print_separator         
| Копирование за месяц > month <значение месяца> (01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12)
| Копирование за год > year

Подробная справка: help

> > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > 
Исходная директория: $source_path
Директория резервного копирования: $destination_path
           
"@

Set-Alias -name month -value backuping_to_month
Set-Alias -name year -value backuping_to_year
Set-Alias -name help -value get_script_info


function backuping ($mask, $folder) {
    $get_files_operation = Get-ChildItem -Path $source_path | Where-Object Name -Match $mask

    $get_files_operation | Copy-Item -Destination $destination_path$folder
            
    if ($? -eq 'True') {
        $get_files_operation | ForEach-Object {$global:count += 1}
    }
    else {
        Write-Output 'Файлы не скопированы ! Возникла ошибка.'    
    }        
}


function logging_files_names ($mask, $log_file) {
    Get-ChildItem -Path $source_path | Where-Object Name -Match $mask | ForEach-Object Name | Out-File -FilePath $log_file -Append
}


function logging_result_sum ($log_file) {
    $log = "`n" + "Количество скопированных файлов: " + $global:count
    $log | Out-File -FilePath $log_file -Append
}


function print_result_sum ($month_name) {
    $message = "Успешно! Скопировано файлов: " + $global:count
    Write-Output $month_name
    Write-Output $message
    $print_separator
    
    $global:count = 0
}


function backuping_to_month ($month_value) {
    if ($month_value -eq 01) {
        backuping $file_mask[0] $folders_names[0]
        backuping $eias_file_mask[0] $folders_names[0]
        
        logging_files_names $file_mask[0] $log_files_names[0]
        logging_files_names $eias_file_mask[0] $log_files_names[0]
        logging_result_sum $log_files_names[0]

        print_result_sum $folders_names[0]
    }
    elseif ($month_value -eq 02) {    
        backuping $file_mask[1] $folders_names[1]
        backuping $eias_file_mask[1] $folders_names[1]
        
        logging_files_names $file_mask[1] $log_files_names[1]
        logging_files_names $eias_file_mask[1] $log_files_names[1]
        logging_result_sum $log_files_names[1]

        print_result_sum $folders_names[1]
    }
    elseif ($month_value -eq 03) {   
        backuping $file_mask[2] $folders_names[2]
        backuping $eias_file_mask[2] $folders_names[2]
        
        logging_files_names $file_mask[2] $log_files_names[2]
        logging_files_names $eias_file_mask[2] $log_files_names[2]
        logging_result_sum $log_files_names[2]

        print_result_sum $folders_names[2]
    }
    elseif ($month_value -eq 04) {    
        backuping $file_mask[3] $folders_names[3]
        backuping $eias_file_mask[3] $folders_names[3]
        
        logging_files_names $file_mask[3] $log_files_names[3]
        logging_files_names $eias_file_mask[3] $log_files_names[3]
        logging_result_sum $log_files_names[3]

        print_result_sum $folders_names[3]
    }
    elseif ($month_value -eq 05) {    
        backuping $file_mask[4] $folders_names[4]
        backuping $eias_file_mask[4] $folders_names[4]
        
        logging_files_names $file_mask[4] $log_files_names[4]
        logging_files_names $eias_file_mask[4] $log_files_names[4]
        logging_result_sum $log_files_names[4]

        print_result_sum $folders_names[4]
    }
    elseif ($month_value -eq 06) {    
        backuping $file_mask[5] $folders_names[5]
        backuping $eias_file_mask[5] $folders_names[5]
        
        logging_files_names $file_mask[5] $log_files_names[5]
        logging_files_names $eias_file_mask[5] $log_files_names[5]
        logging_result_sum $log_files_names[5]

        print_result_sum $folders_names[5]
    }
    elseif ($month_value -eq 07) {    
        backuping $file_mask[6] $folders_names[6]
        backuping $eias_file_mask[6] $folders_names[6]
        
        logging_files_names $file_mask[6] $log_files_names[6]
        logging_files_names $eias_file_mask[6] $log_files_names[6]
        logging_result_sum $log_files_names[6]

        print_result_sum $folders_names[6]
    }
    elseif ($month_value -eq 08) {    
        backuping $file_mask[7] $folders_names[7]
        backuping $eias_file_mask[7] $folders_names[7]
        
        logging_files_names $file_mask[7] $log_files_names[7]
        logging_files_names $eias_file_mask[7] $log_files_names[7]
        logging_result_sum $log_files_names[7]

        print_result_sum $folders_names[7]
    }
    elseif ($month_value -eq 09) {    
        backuping $file_mask[8] $folders_names[8]
        backuping $eias_file_mask[8] $folders_names[8]
        
        logging_files_names $file_mask[8] $log_files_names[8]
        logging_files_names $eias_file_mask[8] $log_files_names[8]
        logging_result_sum $log_files_names[8]

        print_result_sum $folders_names[8]
    }
    elseif ($month_value -eq 10) {    
        backuping $file_mask[9] $folders_names[9]
        backuping $eias_file_mask[9] $folders_names[9]
        
        logging_files_names $file_mask[9] $log_files_names[9]
        logging_files_names $eias_file_mask[9] $log_files_names[9]
        logging_result_sum $log_files_names[9]

        print_result_sum$folders_names[9]
    }
    elseif ($month_value -eq 11) {    
        backuping $file_mask[10] $folders_names[10]
        backuping $eias_file_mask[10] $folders_names[10]
        
        logging_files_names $file_mask[10] $log_files_names[10]
        logging_files_names $eias_file_mask[10] $log_files_names[10]
        logging_result_sum $log_files_names[10]

        print_result_sum $folders_names[10]
    }
    elseif ($month_value -eq 12) {    
        backuping $file_mask[11] $folders_names[11]
        backuping $eias_file_mask[11] $folders_names[11]
        
        logging_files_names $file_mask[11] $log_files_names[11]
        logging_files_names $eias_file_mask[11] $log_files_names[11]
        logging_result_sum $log_files_names[11]

        print_result_sum $folders_names[11]
    }
}


function backuping_to_year {
    $i = 0
    
    while ($i -le 11) {
        backuping $file_mask[$i] $folders_names[$i]
        backuping $eias_file_mask[$i] $folders_names[$i]
        
        $global:year_sum += $global:count

        logging_files_names $file_mask[$i] $log_files_names[$i]
        logging_files_names $eias_file_mask[$i] $log_files_names[$i]
        logging_result_sum $log_files_names[$i]

        print_result_sum $folders_names[$i]
                       
        $i++
    }
    $out = "Скопировано файлов за год: " + $global:year_sum + "`n"
    Write-Output $out

    $global:year_sum = 0
}


function create_month_directories ($path = $destination_path) {
    foreach ($dir_name in $monthes_folders_names) {New-Item -Path "$path$dir_name" -Type "directory"}
}


function find_scan_at_number ($name_mask, $path_to_find = $destination_path) {
    Get-ChildItem -Filter $name_mask* -Path $path_to_find -File
}


function copy_found_files ($path_to_copy) {
    foreach ($file in $found_files_list) {Copy-Item $file -Destination $path_to_copy}
}


function get_script_info {
    Get-Help .\PDF_protocols_backup.ps1
}

# Обновить инфо !
<#
.SYNOPSIS
    Сценарий PDF_protocols_backuo.ps1
.DESCRIPTION
    backuping_to_month <value>     Копировать за месяц. Параметры: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12]  
    backuping_to_year              Копировать за год
    create_month_directories <.>    Создать папки по месяцам. Параметры: [путь(необязательный)]
    find_scan_at_number <mask>     Поиск файлов по маске. Параметры: [маска поиска, путь(необязательный)]
.EXAMPLE
    backuping_to_month 02
    backuping_to_year
    create_month_directories      (create_month_directories C:\Directory)
    find_scan_at_number 123-a*    (find_scan_at_number 123-a* C:\Directory)       
 #>
