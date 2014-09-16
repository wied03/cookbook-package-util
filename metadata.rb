# Encoding: utf-8
name             'bsw_package_util'
maintainer       'BSW Technology Consulting LLC'
maintainer_email 'support@bswtechconsulting.com'
license          ''
description      'Installs/Configures packages based on a CSV baseline'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'yum', '3.3.0'
depends 'bsw_gpg', '0.2.1'
