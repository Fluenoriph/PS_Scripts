$month_library = @{
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


$source_path = $home + '\Desktop\сканы' 

$destination_path = $home + '\Desktop\result_test\'      

function create_month_directories ($path = $destination_path) {
    foreach ($month_name in $month_library.keys) {

        $folder = $month_library[$month_name].folder_name
        New-Item -Path "$path$folder" -Type "directory"}
}











