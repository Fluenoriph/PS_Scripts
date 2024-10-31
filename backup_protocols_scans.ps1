#chcp 65001
#param ($source_type)
$source_type = 'C:\Users\Mahabhara\Desktop\сканы' 

#param ($destination_path)  
$destination_path = $home + "\Desktop\result_test\Январь"                              

# $monthes_paths = ('\январь', '\февраль', '\март', '\апрель', '\май', '\июнь', '\июль', '\август', '\сентябрь', '\октябрь', '\ноябрь', '\декабрь')    ???????

$monthes_dict = @{
    January = "\d+-\w+-\d{2}\.01\.\d{4}\.jpg"
    February = "\d+-\w+-\d{2}\.02\.\d{4}\.jpg"
    March = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf" 
    April = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    May = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    June = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    July = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    August = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    September = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    October = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    November = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
    December = "\d+-\w+-\d{2}\.01\.\d{4}\.pdf"
}

Get-ChildItem $source_type | Where-Object Name -Match $monthes_dict.January | Copy-Item -Destination $destination_path








