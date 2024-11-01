function create_the_database ($name) {
    $global:database_name = $name

    Set-Location C:\
    .\sqlite3 $database_name
} 


function open_the_database ($current_name = $database_name) {
    $database_path = 'C:\Users\Mahabhara\PycharmProjects\Lab_Calcs\' + $current_name
    $message = 'Current database - ' + $database_path
    $out_message = Write-Verbose -Message $message -Verbose
    $out_message
    C:\sqlite3
}
