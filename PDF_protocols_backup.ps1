# **************************************

# Nebula Script. Backup-PDF Mod
# (c) Ivan Bogdanov. 2025
# My contacts: fluenoriph@gmail.com, fluenoriph@yandex.ru
# Powered by Open Source 

# **************************************

         
$work_dirs = Get-Content -Path .\work_pathes.txt -TotalCount 2 -Encoding utf8 
$source_path = $work_dirs[0]
$destination_path = $work_dirs[1]
 
$global:count = 0; $global:year_sum = 0

$work_library = @{
    January = @{
        value = 01;
        folder_name = 'Январь';
        file_mask = "^\d+-\w+-\d{2}\.01\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.01\.\d{4}\.pdf$";
        log_file = '.\logs\january_backup_log.txt'
    }
    February = @{
        value = 02;
        folder_name = 'Февраль';
        file_mask = "^\d+-\w+-\d{2}\.02\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.02\.\d{4}\.pdf$";
        log_file = '.\logs\february_backup_log.txt'
    }
    March = @{
        value = 03;
        folder_name = 'Март';
        file_mask = "^\d+-\w+-\d{2}\.03\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.03\.\d{4}\.pdf$";
        log_file = '.\logs\march_backup_log.txt'
    }
    April = @{
        value = 04;
        folder_name = 'Апрель';
        file_mask = "^\d+-\w+-\d{2}\.04\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.04\.\d{4}\.pdf$";
        log_file = '.\logs\april_backup_log.txt'
    }
    May = @{
        value = 05;
        folder_name = 'Май';
        file_mask = "^\d+-\w+-\d{2}\.05\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.05\.\d{4}\.pdf$";
        log_file = '.\logs\may_backup_log.txt'
    }
    June = @{
        value = 06;
        folder_name = 'Июнь';
        file_mask = "^\d+-\w+-\d{2}\.06\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.06\.\d{4}\.pdf$";
        log_file = '.\logs\june_backup_log.txt' 
    }
    July = @{
        value = 07;
        folder_name = 'Июль';
        file_mask = "^\d+-\w+-\d{2}\.07\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.07\.\d{4}\.pdf$";
        log_file = '.\logs\july_backup_log.txt' 
    }
    August = @{
        value = 08;
        folder_name = 'Август';
        file_mask = "^\d+-\w+-\d{2}\.08\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.08\.\d{4}\.pdf$";
        log_file = '.\logs\august_backup_log.txt' 
    }
    September = @{
        value = 09;
        folder_name = 'Сентябрь';
        file_mask = "^\d+-\w+-\d{2}\.09\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.09\.\d{4}\.pdf$";
        log_file = '.\logs\september_backup_log.txt' 
    }
    October = @{
        value = 10;
        folder_name = 'Октябрь';
        file_mask = "^\d+-\w+-\d{2}\.10\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.10\.\d{4}\.pdf$";
        log_file = '.\logs\october_backup_log.txt' 
    }
    November = @{
        value = 11;
        folder_name = 'Ноябрь';
        file_mask = "^\d+-\w+-\d{2}\.11\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.11\.\d{4}\.pdf$";
        log_file = '.\logs\november_backup_log.txt' 
    }
    December = @{
        value = 12;
        folder_name = 'Декабрь';
        file_mask = "^\d+-\w+-\d{2}\.12\.\d{4}\.pdf$";
        eias_file_mask = "^\d{5}-\d{2}-\d{2}-\d{2}\.12\.\d{4}\.pdf$";
        log_file = '.\logs\december_backup_log.txt' 
    }
}

$separatop = '- - - - - - - - - - - - - - - - - - - - - - - - - - - -'
$print_separator = Write-Output $separatop
$flow_separator = '> > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > >'
$print_flow_separator = Write-Output $flow_separator
$error_message = "Файлы не скопированы ! Возникла ошибка."
$message_no_files = "Файлов не найдено !"


Write-Host @"
$print_separator  
    >> Резервное копирование сканов протоколов << 
$print_separator         
| Копирование за месяц > 'month <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Копирование за год > 'year'
| Поиск протокола по номеру > 'find <номер>' (123-A; 12345-01-02)
| Получить отчет за месяц > 'report <значение месяца>' (01; 02; 03; 04; 05; 06; 07; 08; 09; 10; 11; 12)
| Создание папок по месяцам > 'cmds' ([директория по умолчанию]) 

  Подробная справка: 'help'
$print_flow_separator 
Исходная директория: $source_path
Директория резервного копирования: $destination_path
           
"@

Set-Alias -name month -value backuping_to_month
Set-Alias -name year -value backuping_to_year
Set-Alias -name help -value get_script_info
Set-Alias -name cmds -value create_month_folders
Set-Alias -name find -value find_protocol_at_number
Set-Alias -name report -value get_log_info

function backuping ($mask, $folder) {
    $get_files_operation = Get-ChildItem -Path $source_path | Where-Object Name -Match $mask
    $get_files_operation | Copy-Item -Destination $destination_path$folder
            
    if ($? -eq 'True') {
        $get_files_operation | ForEach-Object {$global:count += 1}
    }
    else {
        Write-Host $error_message
        $print_separator    
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
    if ($global:count -gt 0) {
        $message = "Успешно ! Скопировано файлов: " + $global:count
        Write-Host $month_name
        Write-Host $message
        $print_separator
        $global:count = 0
    }
    else {
        Write-Host $message_no_files
        $print_separator
    }
}

function backuping_to_month ($value) {
    switch ($value) {
        01 {
            backuping $work_library.January['file_mask'] $work_library.January['folder_name']
            backuping $work_library.January['eias_file_mask'] $work_library.January['folder_name']
            logging_files_names $work_library.January['file_mask'] $work_library.January['log_file']
            logging_files_names $work_library.January['eias_file_mask'] $work_library.January['log_file']
            logging_result_sum $work_library.January['log_file']
            print_result_sum $work_library.January['folder_name']
        }
        02 {    
            backuping $work_library.February['file_mask'] $work_library.February['folder_name']
            backuping $work_library.February['eias_file_mask'] $work_library.February['folder_name']
            logging_files_names $work_library.February['file_mask'] $work_library.February['log_file']
            logging_files_names $work_library.February['eias_file_mask'] $work_library.February['log_file']
            logging_result_sum $work_library.February['log_file']
            print_result_sum $work_library.February['folder_name']
        }
        03 {   
            backuping $work_library.March['file_mask'] $work_library.March['folder_name']
            backuping $work_library.March['eias_file_mask'] $work_library.March['folder_name']
            logging_files_names $work_library.March['file_mask'] $work_library.March['log_file']
            logging_files_names $work_library.March['eias_file_mask'] $work_library.March['log_file']
            logging_result_sum $work_library.March['log_file']
            print_result_sum $work_library.March['folder_name']
        }
        04 {    
            backuping $work_library.April['file_mask'] $work_library.April['folder_name']
            backuping $work_library.April['eias_file_mask'] $work_library.April['folder_name']
            logging_files_names $work_library.April['file_mask'] $work_library.April['log_file']
            logging_files_names $work_library.April['eias_file_mask'] $work_library.April['log_file']
            logging_result_sum $work_library.April['log_file']
            print_result_sum $work_library.April['folder_name']
        }
        05 {    
            backuping $work_library.May['file_mask'] $work_library.May['folder_name']
            backuping $work_library.May['eias_file_mask'] $work_library.May['folder_name']
            logging_files_names $work_library.May['file_mask'] $work_library.May['log_file']
            logging_files_names $work_library.May['eias_file_mask'] $work_library.May['log_file']
            logging_result_sum $work_library.May['log_file']
            print_result_sum $work_library.May['folder_name']
        }
        06 {    
            backuping $work_library.June['file_mask'] $work_library.June['folder_name']
            backuping $work_library.June['eias_file_mask'] $work_library.June['folder_name']
            logging_files_names $work_library.June['file_mask'] $work_library.June['log_file']
            logging_files_names $work_library.June['eias_file_mask'] $work_library.June['log_file']
            logging_result_sum $work_library.June['log_file']
            print_result_sum $work_library.June['folder_name']
        }
        07 {    
            backuping $work_library.July['file_mask'] $work_library.July['folder_name']
            backuping $work_library.July['eias_file_mask'] $work_library.July['folder_name']
            logging_files_names $work_library.July['file_mask'] $work_library.July['log_file']
            logging_files_names $work_library.July['eias_file_mask'] $work_library.July['log_file']
            logging_result_sum $work_library.July['log_file']
            print_result_sum $work_library.July['folder_name']
        }
        08 {    
            backuping $work_library.August['file_mask'] $work_library.August['folder_name']
            backuping $work_library.August['eias_file_mask'] $work_library.August['folder_name']
            logging_files_names $work_library.August['file_mask'] $work_library.August['log_file']
            logging_files_names $work_library.August['eias_file_mask'] $work_library.August['log_file']
            logging_result_sum $work_library.August['log_file']
            print_result_sum $work_library.August['folder_name']
        }
        09 {    
            backuping $work_library.September['file_mask'] $work_library.September['folder_name']
            backuping $work_library.September['eias_file_mask'] $work_library.September['folder_name']
            logging_files_names $work_library.September['file_mask'] $work_library.September['log_file']
            logging_files_names $work_library.September['eias_file_mask'] $work_library.September['log_file']
            logging_result_sum $work_library.September['log_file']
            print_result_sum $work_library.September['folder_name']
        }
        10 {    
            backuping $work_library.October['file_mask'] $work_library.October['folder_name']
            backuping $work_library.October['eias_file_mask'] $work_library.October['folder_name']
            logging_files_names $work_library.October['file_mask'] $work_library.October['log_file']
            logging_files_names $work_library.October['eias_file_mask'] $work_library.October['log_file']
            logging_result_sum $work_library.October['log_file']
            print_result_sum $work_library.October['folder_name']
        }
        11 {    
            backuping $work_library.November['file_mask'] $work_library.November['folder_name']
            backuping $work_library.November['eias_file_mask'] $work_library.November['folder_name']
            logging_files_names $work_library.November['file_mask'] $work_library.November['log_file']
            logging_files_names $work_library.November['eias_file_mask'] $work_library.November['log_file']
            logging_result_sum $work_library.November['log_file']
            print_result_sum $work_library.November['folder_name']
        }
        12 {    
            backuping $work_library.December['file_mask'] $work_library.December['folder_name']
            backuping $work_library.December['eias_file_mask'] $work_library.December['folder_name']
            logging_files_names $work_library.December['file_mask'] $work_library.December['log_file']
            logging_files_names $work_library.December['eias_file_mask'] $work_library.December['log_file']
            logging_result_sum $work_library.December['log_file']
            print_result_sum $work_library.December['folder_name']
        }
        default {'* Введите корректное значение !' + "`n"}
    }
}

function backuping_to_year {  
    foreach ($month_name in $work_library.keys) {
        $file_mask = $work_library[$month_name].file_mask
        $eias_file_mask = $work_library[$month_name].eias_file_mask
        $folder = $work_library[$month_name].folder_name
        $log_file = $work_library[$month_name].log_file
        
        backuping $file_mask $folder
        backuping $eias_file_mask $folder
        $global:year_sum += $global:count
        logging_files_names $file_mask $log_file
        logging_files_names $eias_file_mask $log_file
        logging_result_sum $log_file
        print_result_sum $folder               
    }
    $out = "Скопировано файлов за год: " + $global:year_sum + "`n"
    Write-Host $out
    $global:year_sum = 0
}

function create_month_folders ($path = $destination_path) {
    foreach ($month_name in $work_library.keys) {
        $folder = $work_library[$month_name].folder_name
        New-Item -Path "$path$folder" -Type "directory"}
}

function find_protocol_at_number ($mask, $path = $destination_path) {
    $find_operation = Get-ChildItem -Filter $mask* -Path $path -File
    $find_operation
    $print_flow_separator
    Write-Host "Копировать на рабочий стол ?"
    $selector = Read-Host "Нажмите 'Y' (да) или 'N' (нет)"
    
    if ($selector -ieq 'Y') {
        $find_operation | Copy-Item -Destination {$home + '\Desktop'}
        if ($? -eq 'True') {
            Write-Host ''
            Write-Host "Успешно!"
        }
        else {
            Write-Host $error_message    
        }       
    }
    else {break}
}

function get_log_info ($value) {
    switch ($value) {
        01 {
            Write-Host ''
            Get-Content $work_library.January.log_file
            Write-Host ''
        }
        02 {
            Write-Host ''
            Get-Content $work_library.February.log_file
            Write-Host ''
        }
        03 {
            Write-Host ''
            Get-Content $work_library.March.log_file
            Write-Host ''
        }
        04 {
            Write-Host ''
            Get-Content $work_library.April.log_file
            Write-Host ''
        }
        05 {
            Write-Host ''
            Get-Content $work_library.May.log_file
            Write-Host ''
        }
        06 {
            Write-Host ''
            Get-Content $work_library.June.log_file
            Write-Host ''
        }
        07 {
            Write-Host ''
            Get-Content $work_library.July.log_file
            Write-Host ''
        }
        08 {
            Write-Host ''
            Get-Content $work_library.August.log_file
            Write-Host ''
        }
        09 {
            Write-Host ''
            Get-Content $work_library.September.log_file
            Write-Host ''
        }
        10 {
            Write-Host ''
            Get-Content $work_library.October.log_file
            Write-Host ''
        }
        11 {
            Write-Host ''
            Get-Content $work_library.November.log_file
            Write-Host ''
        }
        12 {
            Write-Host ''
            Get-Content $work_library.December.log_file
            Write-Host ''
        }
        default {'* Введите корректное значение !' + "`n"}
    }
}

function get_script_info {
    Get-Help .\PDF_protocols_backup.ps1
}


<#
.SYNOPSIS
    Сценарий PDF_protocols_backup.ps1

    * Nebula Script. Backup-PDF Mod 
    * (c) Ivan Bogdanov. 2025 
    * Powered by Open Source 
.DESCRIPTION
    backuping_to_month <value>      Копировать за месяц. Параметры: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12]  
    backuping_to_year               Копировать за год
    find_protocol_at_number <mask>  Поиск файлов по маске. Параметры: [маска поиска, путь(необязательный)]
    get_log_info <value>            Вывести отчет за месяц. Параметры: [01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12] 
    create_month_folders <.>        Создать папки по месяцам. Параметры: [путь(необязательный)]
.EXAMPLE
    backuping_to_month 02
    backuping_to_year
    find_protocol_at_number 123-A      (find_protocol_at_number 123-A C:\Directory)
    get_log_info 10
    create_month_folders               (create_month_folders C:\Directory)
.NOTES
    Псевдонимы функций:

    backuping_to_month >> month
    backuping_to_year >> year
    find_protocol_at_number >> find
    get_log_info >> report
    create_month_folders >> cmds
    get_script_info >> help
 #>
