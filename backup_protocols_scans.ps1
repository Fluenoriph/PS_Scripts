param($month_value)

$source_path = $home + '\Desktop\сканы' 

$destination_path = $home + '\Desktop\result_test\'                              

$monthes_folders_names = ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь') 

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

$simple_files_count = 0; $eias_files_count = 0

if ($month_value -eq 01) {
    $result_folder = $destination_path + $monthes_folders_names[0]

    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | Copy-Item -Destination $result_folder 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | ForEach-Object Name | Out-File -FilePath .\logging.txt
    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | ForEach-Object {$simple_files_count += 1}
    
    $month_mask.January = $eias_month_mask[0]

    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | Copy-Item -Destination $result_folder 
    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | ForEach-Object Name | Out-File -FilePath .\logging.txt -Append
    Get-ChildItem -Path $source_path | Where-Object Name -Match $month_mask.January | ForEach-Object {$eias_files_count += 1}
        
    $result_count = "`nКоличество скопированных файлов: " + ($simple_files_count + $eias_files_count)
    $result_count | Out-File -FilePath .\logging.txt -Append
}




