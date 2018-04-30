# Returns an array of base filenames for all OS PXEboot files contained
# in the input Hash
#
# @param os_file_info Hash of Hashes.  The outer Hash key is either
#   'bios' or 'efi', corresponding to BIOS or UEFI boot, respectively.
#   The inner Hash is a Hash of Arrays. Each inner Hash key is an
#   OS package.  Each inner Hash value is the list of PXEboot files
#   provided by the named package.  See the module data for specifics.
#
# @return [Array] Array of base filenames
function tftpboot::get_os_base_filenames(Hash $os_file_info) {
  $base_filenames = $os_file_info.map | String $boot_type, Hash $file_info | {
    $file_info.map | String $pkg_name, Array $files| {
      $files.map | String $file | { basename($file) }
    }
  }

  flatten($base_filenames)
}
