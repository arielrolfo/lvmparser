
#require 'csv'
## file has to be /tmp/mylvm.csv and has to contain 1st line as col headers
result = []


_dia = `test -d /pepe && echo ok || echo nok`

puts "Today is: #{_dia}"

File.open('mylvm.csv','r') do |handle|
	handle.each do |line|

		## check how many elements the line has, it MUST be 7
		_myarrayline = line.split(';').reject(&:empty?)
		puts _myarrayline.to_s
		puts _myarrayline.count

		if _myarrayline.count == 7
		    _vgname = line.split(';')[0].strip
		    _lvname = line.split(';')[1].strip
		    _fstype = line.split(';')[2].strip
		    _fssize = line.split(';')[3].strip
		    _fssizeunit = line.split(';')[4].strip
		    _mountpoint = line.split(';')[5].strip
		    _options = line.split(';')[6].strip

		    next if _vgname == "vgname" || _vgname == ""
		    next if _lvname == ""
		    next if _fstype == ""
		    next if _fssize == ""
		    next if _fssizeunit == ""
		    next if _mountpoint == ""
		    next if _options == ""



		    if _fssizeunit != "M" and _fssizeunit != "G"
		    	puts "ERROR UNITS #{_fssizeunit}"
		    	next
		    end

		    if _fstype != "xfs" and _fssizeunit != "ext3" and _fssizeunit != "ext4"
		    	puts "ERROR FSTYPE #{_fssizeunit}"
		    	next
		    end

		    #puts "INFO: creating VG:"
		    #puts "vgcreate #{_vgname}"
		    vgscheck = `vgs 2> /dev/null | grep #{_vgname} | wc -l`
		    puts "INFO creating LV:"
		    puts "lvcreate -L #{_fssize}#{_fssizeunit}  -n #{_lvname} #{_vgname}"
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
	end
	puts
	puts
end


#result.flatten!


