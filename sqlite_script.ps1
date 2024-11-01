chcp 65001


function create_the_database ($name) {
    Set-Location C:\
    .\sqlite3 $name
} 


function open_the_database ($current_name = 'register_data.db') {
    $database_path = 'C:\Users\Mahabhara\PycharmProjects\Lab_Calcs\' + $current_name
    $message = 'Current database - ' + $database_path
    $out_message = Write-Verbose -Message $message -Verbose
    $out_message
    C:\sqlite3
}
