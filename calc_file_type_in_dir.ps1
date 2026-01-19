# Суммы каждого типа файла в директории

using namespace System.Collections.Generic

# Исключения и пустой тип файла сделать.


$side_border = '|'
$top_border = "--------------------------------------------------"

$target_dir = Read-Host "`n>>> Введите требуемую директорию"

$calculated_file_sums = [FileTypeSum]::new($target_dir)
$calculated_file_sums = [FileTypeSum]::new($target_dir)

if ($calculated_file_sums.is_correct)
{
    Write-Host "`n> Директория - $($calculated_file_sums.directory) содержит следующие файлы:`n$($top_border)"
    Write-Host "`n> Директория - $($calculated_file_sums.directory) содержит следующие файлы:`n$($top_border)"

    [Dictionary[int, string]] $file_type_link_dict = @{}
    $file_type_link_number = 1
    [Dictionary[int, string]] $file_type_link_dict = @{}
    $file_type_link_number = 1

    foreach ($item in $calculated_file_sums.result_file_sum.GetEnumerator())
    foreach ($item in $calculated_file_sums.result_file_sum.GetEnumerator())
    {        
        Write-Host "$($side_border) $($file_type_link_number) $($side_border) $($item.Key) - [ $($item.Value) ]"

        $file_type_link_dict.Add($file_type_link_number, $item.Key)
        $file_type_link_number++
    }

    Write-Host "$($top_border)`n| Всего файлов: $($calculated_file_sums.all_files_sum)`n"
    Write-Host "$($top_border)`n| Всего файлов: $($calculated_file_sums.all_files_sum)`n"

    $file_type_link_value = Read-Host "> Для вывода файлов введите номер типа и нажмите 'Enter', для отмены введите любой символ"

    if ($file_type_link_dict.ContainsKey($file_type_link_value))
    {
        $out_files = $calculated_file_sums.GetFilesCurrentType($file_type_link_dict[$file_type_link_value])
        Write-Host $top_border

        [Dictionary[int, string]] $each_file_link_dict = @{}
        $each_file_link_number = 1

        foreach ($file in $out_files)
        {
            Write-Host "> $($each_file_link_number) < $($file)"

            $each_file_link_dict.Add($each_file_link_number, $file)
            $each_file_link_number++
        }

        Write-Host $top_border

        $file_link_value = Read-Host "`n> Чтобы открыть файл, введите номер-ссылку и нажмите 'Enter', для отмены введите любой символ"

        if ($each_file_link_dict.ContainsKey($file_link_value))
        {
            Invoke-Item -Path $each_file_link_dict[$file_link_value]
        }
        else 
        {
            return
        }
    }
    else
    {
        return
    }
}
else 
{
    Write-Host "`n* Ошибка скрипта ! Перезапустите заново !`n"
    return
}

        
class FileTypeSum
{
    [string] $directory
    [list[string]] $file_type_list
    [int] $all_files_sum
    [Dictionary[string, int]] $result_file_sum = @{}   
    [bool] $is_correct
        
    FileTypeSum([string] $target_directory)
    {
        $this.directory = $target_directory

        $this.file_type_list = Get-ChildItem -Path $this.directory -Recurse -Force -File | Sort-Object -Property Extension | ForEach-Object {$_.Extension.Replace('.', '').ToUpper()}
        $this.all_files_sum = $this.file_type_list.Count
                        
        $this.ComputeEachFileTypeSum()
                
        $test_sum = 0

        foreach ($item_value in $this.result_file_sum.Values)
        {
            $test_sum += $item_value
        }

        if ($this.all_files_sum -eq $test_sum)
        {
            $this.is_correct = $true
        }
        else 
        {
            $this.is_correct = $false
        }
    }  

    <# Нужно протестить время выполнения алгоритма расчета каждого типа.
        Есть несколько вариантов выполнения.
    #>

    [void] ComputeEachFileTypeSum()
    {
        for ($file_type_index = 0; $file_type_index -lt $this.all_files_sum; $file_type_index++) 
        {
            $start_file_type = $this.file_type_list[$file_type_index]
            
            if (-not $this.result_file_sum.ContainsKey($start_file_type))
            {
                $file_type_count = 1

                for ($start_index = $file_type_index + 1; $start_index -lt $this.all_files_sum; $start_index++)
                {
                    if ($start_file_type -eq $this.file_type_list[$start_index])
                    {
                        $file_type_count += 1
                    }
                }

                $this.result_file_sum.Add($start_file_type, $file_type_count)
            }
        }        
    }

    [System.Object[]] GetFilesCurrentType([string] $file_type)
    {
        # можно сначала создать этот массив всех файлов для поиска
       
        return Get-ChildItem -Path $($this.directory + '\*.' + $file_type) -Recurse -Force -File | Sort-Object -Property Name
    }
}











