Summary: TFTPBoot Puppet Module
Name: pupmod-tftpboot
Version: 4.1.0
Release: 6
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-xinetd >= 2.0.0-0
Requires: pupmod-rsync >= 2.0.0-0
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-tftpboot-test

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module provides the capability to configure your system to tftpboot
various hosts.

Image files are transmitted via rsync but system linking is abstracted.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/tftpboot

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/tftpboot
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/tftpboot

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/tftpboot

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/tftpboot

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/tftpboot/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/tftpboot/plugins /etc/puppet/environments/simp/modules/tftpboot/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-6
- Changed puppet-server requirement to puppet

* Mon Dec 15 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-5
- Made purging pxelinux.cfg optional.

* Tue Aug 12 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-4
- Allow FIPS to be enabled/disabled via hiera.

* Thu Jul 10 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-3
- Diabled FIPS (for now).

* Sun Jun 22 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-2
- Removed MD5 file checksums for FIPS compliance.
- Added FIPS enabling to TFTP boot profile.

* Mon Apr 14 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Collapsed tftpboot::service into tftpboot

* Tue Jan 14 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Update to tftpboot::assign_host to explicitly set the owner, group,
  and mode.

* Thu Jan 09 2014 Nick Markowski <nmarkowski@keywcorp.com> - 2.1.0-0
- Updated module for puppet3/hiera compatibility, and optimized code for lint tests,
  and puppet-rspec.
- Fixed permissions issue on pxe template.

* Tue Oct 08 2013 Kendall Moore <kmoore@keywcorp.com> - 2.0.0-9
- Updated all erb templates to properly scope variables.

* Mon Feb 25 2013 Maintenance
2.0.0-8
- Added a call to $::rsync_timeout to the rsync call since it is now required.
- Create a Cucumber test which ensures that the xinetd service is running, the tftpboot file is in place, and puppet runs successfully.

* Wed Jul 25 2012 Maintenance
2.0.0-7
- Removed the tidy->file loop.

* Wed Apr 11 2012 Maintenance
2.0.0-6
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
2.0.0-5
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
2.0.0-4
- Updated the spec file to not require a separate file list.
- Scoped all of the top level variables.

* Mon Dec 05 2011 Maintenance
2.0.0-3
- Modified the upcase/downcase match to work with an array match puppet > 2.6

* Fri Aug 12 2011 Maintenance
2.0.0-2
- Added some notes about probably wanting 'ksdevice=bootif\nIPAPPEND 2' in
  'extra' if you're kickstarting.

* Tue Mar 29 2011 Maintenance - 2.0.0-1
- The tftpboot module now expects to have an associated rsync space that is
  password protected.
- Updated to use rsync native type

* Tue Jan 11 2011 Maintenance
2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Maintenance - 1-1
- Converting all spec files to check for directories prior to copy.

* Tue May 25 2010 Maintenance
1.0-0
- Removed unnecessary variable.
- Code refactoring.

* Sat Feb 13 2010 Maintenance
0.2-3
- Fixed the annoying preceeding spaces.

* Fri Jan 15 2010 Maintenance
0.2-2
- Now properly set group of tftpboot files to 'nobody'
