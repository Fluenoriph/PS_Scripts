function create_month_directories ($path = $destination_path, $dir_names_list = $monthes_folders_names) {
    foreach ($dir_name in $dir_names_list) {New-Item -Path "$path$dir_name" -Type "directory"}
}


function find_scan_at_number ($name_mask, $path_to_find = $destination_path) {
    Get-ChildItem -Name -Filter $name_mask* -Path $path_to_find -File
}

# Поток выходит в домашнюю директорию !!
$global:found_files_list = find_scan_at_number


function copy_found_files ($path_to_copy) {
    foreach ($file in $found_files_list) {Copy-Item $file -Destination $path_to_copy}
}
