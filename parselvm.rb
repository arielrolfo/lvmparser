#!/usr/bin/env ruby
#require 'csv'
## file has to be /tmp/mylvm.csv and has to contain 1st line as col headers
result = []

if ARGV.length != 1
  puts "Wrong number of arguments"
  exit 1
end

_lvmfile= ARGV[0]


File.open(_lvmfile,'r') do |handle|
        handle.each do |line|

                ## check how many elements the line has, it MUST be 7
                _myarrayline = line.split(';').reject(&:empty?)
                puts _myarrayline.to_s
                puts _myarrayline.count

                if _myarrayline.count >= 5
                    _vgname = line.split(';')[0].strip
                    next if _vgname == "vgname" || _vgname == ""

                    _lvname = line.split(';')[1].strip
                    _pvs = line.split(';')[2].strip
                    _fstype = line.split(';')[3].strip
                    _fssize = line.split(';')[4].strip
                    _fssizeunit = line.split(';')[5].strip
                    _mountpoint = line.split(';')[6].strip
                    _options = line.split(';')[7].strip

                    puts "DEBUG: pvs: |#{_pvs}| fssize: |#{_fssize}|"

                    next if _lvname == ""
                    next if _pvs == "" and _fssize == ""
                    next if _pvs != "" and _fssize != ""
                    next if _pvs == "" and _fssizeunit == ""
                    next if _pvs != "" and _fssizeunit != ""
                    next if _fstype == ""
                    next if _mountpoint == ""
                    next if _options == ""


                    if _fssizeunit != "M" and _fssizeunit != "G" and _pvs == ""
                        puts "ERROR UNITS #{_fssizeunit}"
                        next
                    end

                    if _fstype != "xfs" and _fssizeunit != "ext3" and _fssizeunit != "ext4"
                        puts "ERROR FSTYPE #{_fssizeunit}"
                        next
                    end

                    #puts "INFO: creating VG:"
                    #puts "vgcreate #{_vgname}"
                    _vgscheck = `vgs 2> /dev/null | grep #{_vgname} | wc -l`
                    if _vgscheck.to_i > 0
                      puts "the VG #{_vgname} already exists"
                    end

                    puts "INFO creating LV:"

                    if _pvs == ""
                      ## assuming the user inputs size and units
                      puts "lvcreate -L #{_fssize}#{_fssizeunit}  -n #{_lvname} #{_vgname}"
                    else
                      ## assuming the user input the device as a whole to create the LV in there
                      ## Determine the size of the whole pv in extents units
                        _fssize = `pvdisplay #{_pvs} | grep \"Free PE \"|awk \'{print $3}\'`
                        puts "PV SIZE: #{_fssize.strip}"
                        puts "lvcreate -l #{_fssize.strip} -n #{_lvname} #{_vgname} #{_pvs}"
                    end


                    #puts "vgname:" + _vgname + " - lvname: " + _lvname + " - fssize: " + _fssize

                    puts "INFO: creating filesystem"
                    puts "mkfs.#{_fstype} -f /dev/#{_vgname}/#{_lvname}"

                    puts "INFO: creating mount point"
                    puts "test -d #{_mountpoint} || mkdir -p #{_mountpoint}"

                    puts "INFO: mounting FS"
                    puts "mount /dev/#{_vgname}/#{_lvname} #{_mountpoint}"
                    puts
                else
                        puts "not enough fields"
                end
        puts
        puts "-----------------"
        puts
        end
end
