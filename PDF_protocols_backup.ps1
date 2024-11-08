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


Write-Output @"
- - - - - - - - - - - - - - - - - - - - - - - - - - - -  
    >>> Резервное копирование сканов протоколов <<< 
- - - - - - - - - - - - - - - - - - - - - - - - - - - -          
>> Копирование за месяц > month <значение месяца> (01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12)
>> Копирование за год > year

Подробная справка: help
- - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Исходная директория: $source_path
Директория резервного копирования: $destination_path
           
"@

Set-Alias -name month -value backuping_to_month
Set-Alias -name year -value backuping_to_year
Set-Alias -name help -value get_script_info


function backuping ($mask, $folder) {
    Get-ChildItem -Path $source_path | Where-Object Name -Match $mask | Copy-Item -Destination $destination_path$folder
    
    
    
    <#if ($? -eq 'True') {
        
        Write-Output 'Ok'
    }
    else {
        Write-Output 'Файлы не скопированы ! Возникла ошибка.'    
    }#>                       
}


function logging ($mask, $log_file) {
    #$count = 0

    Get-ChildItem -Path $source_path | Where-Object Name -Match $mask | ForEach-Object Name | Out-File -FilePath $log_file -Append
    #Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask | ForEach-Object {$count += 1}

    
    #$log_result = "`n Количество скопированных файлов: " + $count
    #$print_log_result = 'Успешно !' + $log_result + "`n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" 
     # Проверка на ошибки
    #$log_result | Out-File -FilePath $log_files_names -Append

    #Write-Verbose -Message $print_log_result -Verbose
}


function backuping_to_year {
    $i = 0
    
    while ($i -le 11) {
        backuping $file_mask[$i] $folders_names[$i]

        backuping $eias_file_mask[$i] $folders_names[$i]
                
        $print_current_month = $monthes_folders_names[$i]     #!!!!!!!
        Write-Verbose -Message $print_current_month -Verbose

        logging $month_mask[$i] $eias_month_mask[$i] $log_files_names[$i]
        
        $number_of_files_per_year += $count
                
        $i++
    }
    $print_count_of_year = "Количество за год: " + $number_of_files_per_year
    Write-Verbose -Message $print_count_of_year -Verbose
}


function backuping_to_month ($month_value) {
    if ($month_value -eq 01) {    
        backuping $file_mask[0] $folders_names[0]
        
        backuping $eias_file_mask[0] $folders_names[0]
        
        

        #logging $file_mask[0] $log_files_names[0]
        #logging $eias_file_mask[0] $log_files_names[0]


        #logging $month_mask[0] $eias_month_mask[0] $log_files_names[0]
    }
    elseif ($month_value -eq 02) {    
        backuping $month_mask[1] $eias_month_mask[1] $monthes_folders_names[1]

        logging $month_mask[1] $eias_month_mask[1] $log_files_names[1]
    }
    elseif ($month_value -eq 03) {   
        backuping $month_mask[2] $eias_month_mask[2] $monthes_folders_names[2]

        logging $month_mask[2] $eias_month_mask[2] $log_files_names[2]
    }
    elseif ($month_value -eq 04) {    
        backuping $month_mask[3] $eias_month_mask[3] $monthes_folders_names[3]

        logging $month_mask[3] $eias_month_mask[3] $log_files_names[3]
    }
    elseif ($month_value -eq 05) {    
        backuping $month_mask[4] $eias_month_mask[4] $monthes_folders_names[4]

        logging $month_mask[4] $eias_month_mask[4] $log_files_names[4]
    }
    elseif ($month_value -eq 06) {    
        backuping $month_mask[5] $eias_month_mask[5] $monthes_folders_names[5]

        logging $month_mask[5] $eias_month_mask[5] $log_files_names[5]
    }
    elseif ($month_value -eq 07) {    
        backuping $month_mask[6] $eias_month_mask[6] $monthes_folders_names[6]

        logging $month_mask[6] $eias_month_mask[6] $log_files_names[6]
    }
    elseif ($month_value -eq 08) {    
        backuping $month_mask[7] $eias_month_mask[7] $monthes_folders_names[7]

        logging $month_mask[7] $eias_month_mask[7] $log_files_names[7]
    }
    elseif ($month_value -eq 09) {    
        backuping $month_mask[8] $eias_month_mask[8] $monthes_folders_names[8]

        logging $month_mask[8] $eias_month_mask[8] $log_files_names[8]
    }
    elseif ($month_value -eq 10) {    
        backuping $month_mask[9] $eias_month_mask[9] $monthes_folders_names[9]

        logging $month_mask[9] $eias_month_mask[9] $log_files_names[9]
    }
    elseif ($month_value -eq 11) {    
        backuping $month_mask[10] $eias_month_mask[10] $monthes_folders_names[10]

        logging $month_mask[10] $eias_month_mask[10] $log_files_names[10]
    }
    elseif ($month_value -eq 12) {    
        backuping $month_mask[11] $eias_month_mask[11] $monthes_folders_names[11]

        logging $month_mask[11] $eias_month_mask[11] $log_files_names[11]
    }
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


<#
.SYNOPSIS
    Сценарий backup_protocols_scans.ps1
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
