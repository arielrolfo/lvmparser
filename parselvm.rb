
require 'csv'
## file has to be /tmp/mylvm.csv and has to contain 1st line as col headers
result = []
File.open('/tmp/mylvm.csv','r') do |handle|
  handle.each do |line|

    _vgname = line.split(';')[0]
    _lvname = line.split(';')[1]
    _fstype = line.split(';')[2]
    _fssize = line.split(';')[3]
    _fssizeunit = line.split(';')[4]
    _mountpoint = line.split(';')[5]
    _options = line.split(';')[6]
    next if _vgname == "vgname"

    if _fssizeunit != "M" and _fssizeunit != "G"
    	puts "ERROR UNITS #{_fssizeunit}"
    end

    puts "INFO: creating VG:"
    puts "vgcreate #{_vgname}"
    puts "INFO creating LV:"
    puts "lvcreate -L #{_fssize}#{_fssizeunit}  -n #{_lvname} #{_vgname}"
    #puts "vgname:" + _vgname + " - lvname: " + _lvname + " - fssize: " + _fssize

    puts "INFO: creating filesystem"
    puts "mkfs.#{_fstype} -f /dev/#{_vgname}/#{_lvname}" 

    puts "INFO: creating mount point"
    puts "test -d #{_mountpoint} || mkdir -p #{_mountpoint}"

    puts "INFO: mounting FS"
    puts "mount #{_mountpoint}"
    puts
  end
end


#result.flatten!


