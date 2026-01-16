# Суммы каждого типа файла в директории

using namespace System.Collections.Generic

# Исключения и пустой тип файла сделать.


$side_border = '|'
$top_border = "--------------------------------------------------"

$target_dir = Read-Host "`n>>> Введите требуемую директорию"

$calc_file_sums = [FileTypeSum]::new($target_dir)

if ($calc_file_sums.is_correct)
{
    Write-Host "`n> Директория - $($calc_file_sums.directory) содержит следующие файлы:`n$($top_border)"

    [Dictionary[int, string]] $file_type_link = @{}
    $link = 1

    foreach ($item in $calc_file_sums.result_file_sum.GetEnumerator())
    {        
        Write-Host "$($side_border) $($link): $($item.Key) - [ $($item.Value) ]"

        $file_type_link.Add($link, $item.Key)
        $link++
    }

    Write-Host "$($top_border)`n| Всего файлов: $($calc_file_sums.all_files_sum)`n"

    $link_value = Read-Host "> Для вывода файлов введите номер типа и нажмите 'Enter', для отмены введите любой символ"

    if ($file_type_link.ContainsKey($link_value))
    {
        $out_files = $calc_file_sums.GetFilesCurrentType($file_type_link[$link_value])
        Write-Host $top_border

        foreach ($file in $out_files)
        {
            Write-Host $file
        }
        Write-Host $top_border
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











