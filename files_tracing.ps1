$data_month = @{01 = "Январь"; 02 = "Февраль"; 03 = "Март"; 04 = "Апрель"; 05 = "Май"; 06 = "Июнь"; 07 = "Июль"; 08 = "Август"; 09 = "Сентябрь"; 10 = "Октябрь"; 11 = "Ноябрь"; 12 = "Декабрь"}

$p = 'C:\Users\Mahabhara\Desktop\сканы'

$month_value = '01'

$rgx = ('^\d{1,4}-\p{IsCyrillic}{1,2}-', '^\d{5}-\d{2}-\d{2}-', '[ф]', '[р]', '[м]', '[ф][а]', '[р][а]', '[м][а]')

$files = @(@(), @())

foreach ($i in (0, 1)) {
    $files[$i] = Get-ChildItem -Path $p | Where-Object Name -Match $($rgx[$i] + "\d{2}\.$month_value\.\d{4}\.pdf$")
}


# **********************************************
function get_protocol_numbers {
    $n = $files[0] | Where-Object Name -Match '^(?<number>\d+)-[ф][а]-' | ForEach-Object {[int]$Matches.number} | Sort-Object    # номера типа протокола

    $x = New-Object System.Collections.ArrayList
    $x.AddRange($n[0]..$n[-1])

    $n.GetEnumerator().ForEach({$x.Remove($_)})    # пропущенные номера
    $x
}






